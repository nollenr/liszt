module RecipesHelper

  #used in the recipe model by the ocrize function
  def log_activity_to_record(id, message)
    # Update informational debugging data
    existingdata = Recipe.select(:attachment_processing_output).find(id)
    message = existingdata.attachment_processing_output.to_s.empty? ? message : existingdata.attachment_processing_output.to_s + "\n" + message
    Recipe.update_all({attachment_processing_output: message},{id: id})
    # End information debugging data
  end
  
end
