class AddForeignKeyFromRecipiesToRecipeIngredients < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE recipe_ingredients ADD CONSTRAINT recipe_ingredients_fk_001 FOREIGN KEY (recipe_id) REFERENCES recipes(id)'
  end

  def down
    execute 'ALTER TABLE recipe_ingredients DROP CONSTRAINT recipe_ingredients_fk_001'
  end
end
