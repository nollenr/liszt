module RecipesHelper

  #used in the recipe model by the ocrize function
  def log_activity_to_record(id, message)
    # Update informational debugging data
    existing_data = Recipe.select(:attachment_processing_output).find(id)
    existing_data.attachment_processing_output.nil? ? message : message = existing_data.attachment_processing_output + "\n" + message
    Recipe.where(id: id).update_all(attachment_processing_output: message)
    # End information debugging data
  end
  
  def end_ocrize_processing(id, status)
    update_attribute(:attachment_processing_successful, status)
    update_attribute(:attachment_processing_endtime, Time.now)
  end
  
end
