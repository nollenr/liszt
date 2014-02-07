class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.string :name, limit: 40, null: false
      t.integer :user_id, null: false
      t.string :recipe_source, limit: 30
      t.string :recipe_source_desc, limit: 90
      t.attachment :original_attachment
      t.attachment :intermediate_process_attachment
      t.attachment :post_process_attachment
      t.text :attachment_as_text
      t.text :attachment_processing_output
      t.timestamp :attachment_processing_starttime
      t.timestamp :attachment_processing_endtime
      t.boolean :attachment_processing_successful
      t.timestamps
    end
    
    add_index :recipes, [:user_id, :name], unique: true
  end
end
