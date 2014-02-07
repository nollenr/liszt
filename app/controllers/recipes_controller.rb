class RecipesController < ApplicationController
  # rails g scaffold Recipe --no-test-framework
  
  before_filter :signed_in_user
  before_action :set_recipe, only: [:show, :edit, :update]

  # GET /recipes
  def index
    @recipes = current_user.recipes.all
  end

  # GET /recipes/1
  def show
  end

  # GET /recipes/new
  def new
    @recipe = Recipe.new
  end

  # GET /recipes/1/edit
  def edit
  end

  # POST /recipes
  def create
    @recipe = current_user.recipes.new(recipe_params)

    if @recipe.save
      @recipe.delay.ocrize_the_recipe
      redirect_to @recipe, notice: 'Recipe was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /recipes/1
  def update
    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: 'Recipe was successfully updated.'
    else
      render action: 'edit'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recipe
      @recipe = current_user.recipes.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def recipe_params
      params[:recipe].permit(:name, :recipe_source, :recipe_source_desc, :original_attachment, :intermediate_process_attachment, :post_process_attachment)
    end
end
