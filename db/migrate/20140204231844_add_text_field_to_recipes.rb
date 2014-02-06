class AddTextFieldToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :attachment_as_text, :text
  end
end
