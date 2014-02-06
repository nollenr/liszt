class AddAttachmentColumnsToRecipes < ActiveRecord::Migration
  def self.up
    add_attachment :recipes, :pre_process_attachment
    add_attachment :recipes, :post_process_attachment
  end

  def self.down
    remove_attachment :recipes, :pre_process_attachment
    remove_attachment :recipes, :post_process_attachment
  end
end
