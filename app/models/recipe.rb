class Recipe < ActiveRecord::Base
  # In addition to recipes I want "how-to's", like the buiscuit how-to or the chicken dredge how-to
  
  require 'open3'
  
  has_attached_file :pre_process_attachment
  has_attached_file :post_process_attachment
  
  validates_attachment :pre_process_attachment, content_type: {content_type: ["image/jpg", "image/jpeg", "image/gif", "image/png", "application/pdf"]}
  validates_attachment :post_process_attachment, content_type: {content_type: ["text/plain"]}
  
  def ocrize_the_recipe
    sleep 5
    # set up the input and output file names and the tesseract system command
    convert_output_file_name   = 'recipeApp' + SecureRandom.hex(10)
    convert_output_dir_name    = '/tmp'
    convert_output_file_ext    = 'JPG'
    convert_density_setting    = '300'
    convert_depth_setting      = '8'
    tesseract_output_file_name = 'recipeApp' + SecureRandom.hex(10)
    tesseract_output_dir_name  = '/tmp'
    tesseract_output_file_ext  = 'txt'
    tesseract_input_file       = pre_process_attachment.path
    
    ########################
    # Remember to delete the intermediate jpg file from the /tmp directory
    # Save the intermediate (convert file) so that if there are problems I can see them
    ########################
        
    # If the attachment is a pdf, the first thing I have to do is convert it to a JPG
    exit_status_Open3 = nil
    if /\.pdf$/i.match(pre_process_attachment.path)
      system_command = 'convert -density ' + convert_density_setting + ' ' + pre_process_attachment.path + ' -depth ' + convert_depth_setting + ' -append ' + convert_output_dir_name + '/' + convert_output_file_name + '.' + convert_output_file_ext
      Delayed::Worker.logger.debug "********** system command is: #{system_command}"
      Open3.popen3(system_command) do |stdin, stdout, stderr, wait_thr|
        exit_status_Open3 = wait_thr.value
      end
      unless ( /exit 0$/.match(exit_status_Open3.to_s) )
        mydata = "Processing of PDF attachment \"" + pre_process_attachment_path + "\" failed.\n"
        mydata += "Output file destination: \"" + convert_output_dir_name + '/' + convert_output_file_name + '.' + convert_output_file_ext + "\"\n"
        mydata += "Exit status: \"" + exit_status_Open3.to_s + "\n\""
        mydata += "System command: \"" + system_command + "\"\n"
        mydata += "ID: " + id.to_s + "\n\n"
        mydata += "Process output:\n"
        stdout.each do |line|
          mydata += line
        end
        stderr.each do |line|
          mydata += line
        end
        update_attribute(:attachment_as_text, mydata)
        return false
      end
      # Process was successful, but does the convert outputfile exist?
      if File::exists?(convert_output_dir_name + '/' + convert_output_file_name + '.' + convert_output_file_ext)
        # update_attribute(:intermediate_process_attachment, File.open(tesseract_output_dir_name + '/' + tesseract_output_file_name + '.' + tesseract_output_file_ext,'r'))
        tesseract_input_file = convert_output_dir_name + '/' + convert_output_file_name + '.' + convert_output_file_ext
      else
        # Update the text attribute that the convert process returned successfully, but the file did not exist
        return false
      end
    end
    
    # Input file should now be a JPG regardless of the original file type.
    system_command = 'tesseract ' + tesseract_input_file  + ' ' + tesseract_output_dir_name + '/' + tesseract_output_file_name
    Delayed::Worker.logger.debug "********** system command is: #{system_command}"
    
    # run the system command and capture stdout, sterr and status
    exit_status_Open3 = nil
    Open3.popen3(system_command) do |stdin, stdout, stderr, wait_thr|
      #Delayed::Worker.logger.debug "********** stdout: #{stdout.read}"
      #Delayed::Worker.logger.debug "********** stderr: #{stderr.read}"
      Delayed::Worker.logger.debug "********** status: #{wait_thr.value}"
      # If the return code is not zero, then capture stdout and stderr and quit.
      exit_status_Open3 = wait_thr.value
      unless ( /exit 0$/.match(exit_status_Open3.to_s) )
        mydata = "Processing of JPEG attachment \"" + tesseract_input_file + "\" failed.\n"
        mydata += "Output file destination: \"" + tesseract_output_dir_name + '/' + tesseract_output_file_name + '.' + tesseract_output_file_ext + "\"\n"
        mydata += "Exit status: \"" + exit_status_Open3.to_s + "\n\""
        mydata += "System command: \"" + system_command + "\"\n"
        mydata += "ID: " + id.to_s + "\n\n"
        mydata += "Process output:\n"
        stdout.each do |line|
          mydata += line
        end
        stderr.each do |line|
          mydata += line
        end
        update_attribute(:attachment_as_text, mydata)
        return false
      end # end check for exit status
    end #end the Open3.popen3
    
    # read each line of the output text file and update that into a text column
    # assuming that the exit status of tesseract was 0 (which is successful)
    Delayed::Worker.logger.debug "********** checking to see if file exists"
    if File::exists?(tesseract_output_dir_name + '/' + tesseract_output_file_name + '.' + tesseract_output_file_ext)
      mydata=''
      File.foreach(tesseract_output_dir_name + '/' + tesseract_output_file_name + '.' + tesseract_output_file_ext) do |line|
        Delayed::Worker.logger.debug "********** #{line}"
        mydata += line
      end # End the File::foreach
      
      update_attribute(:attachment_as_text, mydata)
      
      # upload the text file into the rails application
      update_attribute(:post_process_attachment, File.open(tesseract_output_dir_name + '/' + tesseract_output_file_name + '.' + tesseract_output_file_ext,'r'))
      
      # delete the temporary file once it is uploaded to the application
      File.delete(tesseract_output_dir_name + '/' + tesseract_output_file_name + '.' + tesseract_output_file_ext)
    else
      # Update the text attribute that the convert process returned successfully, but the file did not exist
      return false
    end # end if File::exists?
  end # end ocrize_the_recipe
  
end
