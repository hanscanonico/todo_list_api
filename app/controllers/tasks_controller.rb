# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :set_list
  before_action :set_task, only: %i[show update destroy]
  before_action :check_list_existence

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

  private

  def set_list
    @list = List.find(params[:list_id])
  end

  def set_task
    @task = @list.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:name, :done)
  end

  def check_list_existence
    return if List.exists?(params[:list_id])

    render json: { error: 'List not found' }, status: :not_found
  end
end
