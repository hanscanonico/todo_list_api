# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :check_list_existence
  before_action :set_list
  before_action :check_task_existence, only: %i[show update destroy toggle switch_order]
  before_action :set_task, only: %i[show update destroy toggle switch_order]

  # GET /lists/:list_id/tasks
  def index
    @tasks = @list.tasks
    render json: @tasks
  end

  # GET /lists/:list_id/tasks/:id
  def show
    render json: @task
  end

  # POST /lists/:list_id/tasks
  def create
    @task = @list.tasks.new(task_params)
    last_task_order = @list.tasks.maximum(:order)
    @task.order = last_task_order ? last_task_order + 1 : 1
    if @task.save
      render json: @task, status: :created, location: list_tasks_url(@list, @task)
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /lists/:list_id/tasks/:id
  def update
    if @task.update(task_params)
      render json: @task
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  # DELETE /lists/:list_id/tasks/:id
  def destroy
    @task.destroy
    render json: { message: 'Task was successfully destroyed.' }
  end

  # PATCH /lists/:list_id/tasks/:id/toggle
  def toggle
    @task = @list.tasks.find(params[:id])
    @task.update(done: !@task.done)
    render json: @task
  end

  # PATCH /lists/:list_id/task/id/switch_order
  def switch_order
    task1 = @list.tasks.find(params[:id])
    task2 = @list.tasks.find(params[:task_id])

    task1_order = task1.order
    task1.update(order: task2.order)
    task2.update(order: task1_order)

    render json: { message: 'Tasks order have been successfully switched.' }
  end

  private

  def set_list
    @list = current_user.lists.find(params[:list_id])
  end

  def set_task
    @task = @list.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:name, :done)
  end

  def check_list_existence
    return if current_user.lists.exists?(params[:list_id])

    render json: { error: 'List not found' }, status: :not_found
  end

  def check_task_existence
    return if current_user.tasks.exists?(params[:id])

    render json: { error: 'Task not found' }, status: :not_found
  end
end
