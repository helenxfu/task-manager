class TasksController < ApplicationController
  before_action :require_user
  before_action :set_task, only: [:edit, :update, :destroy]
  before_action :index_params, only: :index

  def index
    # debugger
    if params[:search]
      @tasks = current_user.tasks.where("name LIKE ?", "%#{params[:search]}%").paginate(page: params[:page], per_page: 50)
    elsif params[:category_id]
      category_id = params[:category_id].to_i
      @tasks = current_user.categories.find(category_id).tasks.paginate(page: params[:page], per_page: 50)
    elsif params[:completion]
      completion = params[:completion] == "true" ? true : false
      @tasks = current_user.tasks.where(completed: completion).paginate(page: params[:page], per_page: 50)
    elsif params[:priority]
      priority = params[:priority].to_i
      @tasks = current_user.tasks.where(priority: priority).paginate(page: params[:page], per_page: 50)
    else
      @tasks = current_user.tasks.paginate(page: params[:page], per_page: 50)
    end
  end

  def new
    @task = Task.new
  end

  def edit
  end

  def create
    @task = current_user.tasks.new(task_params)
    if @task.save
      flash[:success] = "Task created!"
      redirect_to tasks_path
    else
      flash[:danger] = "Task failed: #{@task.errors.full_messages}"
      redirect_back(fallback_location: root_url)
    end
  end

  def update
    if @task.update(task_params)
      flash[:success] = "Task updated!"
      redirect_to tasks_path
    else
      flash[:danger] = "Task update failed: #{@task.errors.full_messages}"
      redirect_back(fallback_location: root_url)
    end
  end

  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: "Task was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def delete_all
    current_user.tasks.delete_all
    flash[:success] = "Task updated!"
    redirect_back(fallback_location: root_url)
  end

  def delete_completed
    current_user.tasks.where(completed: true).delete_all
    flash[:success] = "Deleted completed"
    redirect_back(fallback_location: root_url)
  end

  def filter_tasks(id)
    @tasks = current_user.tasks.where(category: id).paginate(page: params[:page], per_page: 50)
    render tasks
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_task
    @task = Task.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def task_params
    params.require(:task).permit(:name, :priority, :completed, :deadline, category_ids: [])
  end

  def index_params
    # params.permit(:search, :category_id, :completion)
  end
end
