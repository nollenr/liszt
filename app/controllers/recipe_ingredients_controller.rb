class RecipeIngredientsController < ApplicationController
  before_action :set_recipe_ingredient, only: [:show, :edit, :update, :destroy]

  # GET /recipe_ingredients
  def index
    @recipe_ingredients = RecipeIngredient.all
  end

  # GET /recipe_ingredients/1
  def show
  end

  # GET /recipe_ingredients/new
  def new
    @recipe = Recipe.find(41)
    @recipe_ingredient = RecipeIngredient.new
  end

  # GET /recipe_ingredients/1/edit
  def edit
  end

  # POST /recipe_ingredients
  def create
    @recipe_ingredient = RecipeIngredient.new(recipe_ingredient_params)

    if @recipe_ingredient.save
      redirect_to @recipe_ingredient, notice: 'Recipe ingredient was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /recipe_ingredients/1
  def update
    if @recipe_ingredient.update(recipe_ingredient_params)
      redirect_to @recipe_ingredient, notice: 'Recipe ingredient was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /recipe_ingredients/1
  def destroy
    @recipe_ingredient.destroy
    redirect_to recipe_ingredients_url, notice: 'Recipe ingredient was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recipe_ingredient
      @recipe_ingredient = RecipeIngredient.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def recipe_ingredient_params
      params[:recipe_ingredient].permit(:recipe_id, :quantity, :ingredient, :additional_instructions)
    end
end
