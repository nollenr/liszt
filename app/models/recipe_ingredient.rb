class RecipeIngredient < ActiveRecord::Base
  belongs_to :recipe
  
end
