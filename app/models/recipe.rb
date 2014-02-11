class Recipe < ActiveRecord::Base
  # In addition to recipes I want "how-to's", like the buiscuit how-to or the chicken dredge how-to
  
  require 'open3'
  
  include RecipesHelper
  
  belongs_to :user
  
  has_attached_file :original_attachment
  has_attached_file :intermediate_process_attachment
  has_attached_file :post_process_attachment
  
  validates_attachment :original_attachment, content_type: {content_type: ["image/jpg", "image/jpeg", "image/gif", "image/png", "image/tiff", "application/pdf", "text/plain"]}
  validates_attachment :intermediate_process_attachment, content_type: {content_type: ["image/jpg", "image/jpeg"]}
  validates_attachment :post_process_attachment, content_type: {content_type: ["text/plain"]}
  
  def ocrize_the_recipe
    # Update the record to reflect whne processing started
    update_attribute(:attachment_processing_starttime, Time.now)

    # set up the input and output file names and the tesseract system command
    convert_output_file_name   = 'recipeAppJPG' + SecureRandom.hex(10)
    convert_output_dir_name    = '/tmp'
    convert_output_file_ext    = 'JPG'
    convert_density_setting    = '300'
    convert_depth_setting      = '8'
    tesseract_output_file_name = 'recipeAppTXT' + SecureRandom.hex(10)
    tesseract_output_dir_name  = '/tmp'
    tesseract_output_file_ext  = 'txt'
    tesseract_input_file       = original_attachment.path
    
    ########################
    # Remember to delete the intermediate jpg file from the /tmp directory
    ########################

    exit_status_Open3 = nil
    message = Time.now.to_s + ' ' + 'Starting attachment processing.  Original file is: ' + original_attachment.path
    message += "\n" + Time.now.to_s + ' ' + ' Original content type is: ' + original_attachment_content_type
    log_activity_to_record(id, message)
    
    ######################################################################
    #                                                                    #
    # First check to see if the incoming file i9s type text              #
    #                                                                    #
    ######################################################################
    
    if original_attachment_content_type == 'text/plain'
      # Update informational debugging data
      message = Time.now.to_s + ' ' + ' Moving attachment to post_processing_attacment.'
      log_activity_to_record(id, message)
      # End information debugging data
      
      update_attribute(:post_process_attachment, File.open(original_attachment.path,'r'))
      # I don't think I EVER want to get rid of the original attachment
      # or at least give that ability (responsibility?) to the end user.
      #update_attribute(:original_attachment, nil)
      
      # end processing
      end_ocrize_processing(id, true)
      return true
    end 
    
    ######################################################################
    #                                                                    #
    # Below is the convert of a PDF to JPG                               #
    #                                                                    #
    ######################################################################
        
    # If the attachment is a pdf, the first thing I have to do is convert it to a JPG.  This will be the intermediate attachment
    if /\.pdf$/i.match(original_attachment.path)
      system_command = 'convert -density ' + convert_density_setting + ' ' + original_attachment.path + ' -depth ' + convert_depth_setting + ' -append ' + convert_output_dir_name + '/' + convert_output_file_name + '.' + convert_output_file_ext
      Delayed::Worker.logger.debug "********** system command is: #{system_command}"

      # Update informational debugging data
      message = Time.now.to_s + ' ' + 'Attempting PDF conversion with command: ' + system_command
      log_activity_to_record(id, message)
      # End information debugging data
      
      # Run the convert command
      Open3.popen3(system_command) do |stdin, stdout, stderr, wait_thr|
        exit_status_Open3 = wait_thr.value
      end
      
      # Processing unsuccessful according to the return code
      unless ( /exit 0$/.match(exit_status_Open3.to_s) )
        message = Time.now.to_s + " Processing of PDF attachment \"" + original_attachment_path + "\" failed.\n"
        message += "Output file destination: \"" + convert_output_dir_name + '/' + convert_output_file_name + '.' + convert_output_file_ext + "\"\n"
        message += "Exit status: \"" + exit_status_Open3.to_s + "\n\""
        message += "System command: \"" + system_command + "\"\n"
        message += "ID: " + id.to_s + "\n\n"
        message += "Process output:\n"
        stdout.each do |line|
          message += line
        end
        stderr.each do |line|
          message += line
        end
        log_activity_to_record(id, message)
        end_ocrize_processing(id, false)
        return false
      end # End Processing unsuccessful according to the return code
      # Process was successful, but does the convert outputfile exist?
      if File::exists?(convert_output_dir_name + '/' + convert_output_file_name + '.' + convert_output_file_ext)
        # Update informational degugging data
        message = Time.now.to_s + ' ' + 'Successful conversion of PDF to JPG.  Exit status is: ' + exit_status_Open3.to_s
        log_activity_to_record(id, message)
        # End informational debugging data

        # Attach the intermediate file        
        update_attribute(:intermediate_process_attachment, File.open(convert_output_dir_name + '/' + convert_output_file_name + '.' + convert_output_file_ext,'r'))
        tesseract_input_file = convert_output_dir_name + '/' + convert_output_file_name + '.' + convert_output_file_ext
      else
        # Update informational degugging data
        mesasge = Time.now.to_s + ' Convert process reported as successful, but output file "' + convert_output_dir_name + '/' + convert_output_file_name + '.' + convert_output_file_ext + '" reported not to exist.'
        message += "\n" + Time.now.to_s + ' Exit status of convert was ' + exit_status_Open3.to_s
        log_activity_to_record(id, message)
        end_ocrize_processing(id, false)
        # End informational debugging data
        
        return false
      end
    end #End processing the file if the original was a pdf.  

    ######################################################################
    #                                                                    #
    # Above is the conversion of a PDF to a JPG                          #
    # Below is the tesseract (ocr) of a JPG to a TXT file                #
    #                                                                    #
    ######################################################################
    
    # Input file should now be a JPG regardless of the original file type.
    system_command = 'tesseract ' + tesseract_input_file  + ' ' + tesseract_output_dir_name + '/' + tesseract_output_file_name
    Delayed::Worker.logger.debug "********** system command is: #{system_command}"
    
    # Update informational debugging data
    message = Time.now.to_s + ' ' + 'Attempting JPG conversion to text with command: ' + system_command
    log_activity_to_record(id, message)
    # End information debugging data
    
    # run the system command and capture stdout, sterr and status
    exit_status_Open3 = nil
    Open3.popen3(system_command) do |stdin, stdout, stderr, wait_thr|
      #Delayed::Worker.logger.debug "********** stdout: #{stdout.read}"
      #Delayed::Worker.logger.debug "********** stderr: #{stderr.read}"
      Delayed::Worker.logger.debug "********** status: #{wait_thr.value}"
      # If the return code is not zero, then capture stdout and stderr and quit.
      exit_status_Open3 = wait_thr.value
      unless ( /exit 0$/.match(exit_status_Open3.to_s) )
        message = Time.now.to_s + "Processing of JPEG attachment \"" + tesseract_input_file + "\" failed.\n"
        message += "Output file destination: \"" + tesseract_output_dir_name + '/' + tesseract_output_file_name + '.' + tesseract_output_file_ext + "\"\n"
        message += "Exit status: \"" + exit_status_Open3.to_s + "\n\""
        message += "System command: \"" + system_command + "\"\n"
        message += "ID: " + id.to_s + "\n\n"
        message += "Process output:\n"
        stdout.each do |line|
          message += line
        end
        stderr.each do |line|
          message += line
        end
        log_activity_to_record(id, message)
        end_ocrize_processing(id, false)
        return false
      end # end check for exit status
    end #end the Open3.popen3
    
    # read each line of the output text file and update that into a text column
    # assuming that the exit status of tesseract was 0 (which is successful)
    Delayed::Worker.logger.debug "********** checking to see if file exists"
    if File::exists?(tesseract_output_dir_name + '/' + tesseract_output_file_name + '.' + tesseract_output_file_ext)
      log_activity_to_record(id, Time.now.to_s + " Convertion to text file was successful.  Exit status was: " + exit_status_Open3.to_s + " Attaching text output.")
      text_output = ''
      File.foreach(tesseract_output_dir_name + '/' + tesseract_output_file_name + '.' + tesseract_output_file_ext) do |line|
        Delayed::Worker.logger.debug "********** #{line}"
        text_output += line
      end # End the File::foreach
      
      update_attribute(:attachment_as_text, text_output)
      
      # upload the text file into the rails application
      update_attribute(:post_process_attachment, File.open(tesseract_output_dir_name + '/' + tesseract_output_file_name + '.' + tesseract_output_file_ext,'r'))
      
      # delete the temporary file once it is uploaded to the application
      File.delete(tesseract_output_dir_name + '/' + tesseract_output_file_name + '.' + tesseract_output_file_ext)
      
      log_activity_to_record(id, Time.now.to_s + " Processing complete.  Exiting with success")
      end_ocrize_processing(id, true)
    else
      # Update the text attribute that the convert process returned successfully, but the file did not exist
      update_attribute(:attachment_processing_successful, false)
      # Update informational degugging data
      message = "\n" + Time.now.to_s + ' Tesseract process reported as successful, but output file "' + tesseract_output_dir_name + '/' + tesseract_output_file_name + '.' + tesseract_output_file_ext + '" reported not to exist.'
      message += "\n" + Time.now.to_s + ' Exit status of convert was ' + exit_status_Open3.to_s
      log_activity_to_record(id, message)
      end_ocrize_processing(id, false)
      # End informational debugging data
      return false
    end # end if File::exists?
  end # end ocrize_the_recipe
  
end
