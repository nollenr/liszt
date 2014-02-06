class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.string :name, limit: 40, null: false
      t.string :recipe_source, limit: 30
      t.string :recipe_source_desc, limit: 90
      t.timestamps
    end
    
    add_index :recipes, :name, unique: true
  end
end
