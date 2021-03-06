class CategoriesController < ApplicationController
  before_action :require_user
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  def index
    @categories = current_user.categories.paginate(page: params[:page], per_page: 20)
  end

  def show
    @tasks = @category.tasks.paginate(page: params[:page], per_page: 20)
  end

  def new
    @category = Category.new
  end

  def edit
  end

  def create
    @category = current_user.categories.new(category_params)

    if @category.save
      flash[:success] = "category created!"
      redirect_to categories_path
    else
      flash[:danger] = "category create failed: #{@category.errors.full_messages}"
      redirect_back(fallback_location: root_url)
    end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to categories_path, notice: "Category was successfully updated." }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to categories_path, notice: "Category was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_category
    @category = Category.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def category_params
    params.require(:category).permit(:name, :priority)
  end
end
