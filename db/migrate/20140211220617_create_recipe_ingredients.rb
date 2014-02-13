class CreateRecipeIngredients < ActiveRecord::Migration
  def change
    create_table :recipe_ingredients do |t|
      t.integer :recipe_id, null: false
      t.string :quantity, null: false
      t.string :unit_of_measure
      t.string :alternate_quantity
      t.string :alternate_unit_of_measure
      t.string :ingredient, null: false
      t.string :additional_instructions
      t.timestamps
    end
  end
end
