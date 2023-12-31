# frozen_string_literal: true

class ListsController < ApplicationController
  before_action :check_list_existence, only: %i[show update destroy]
  before_action :set_list, only: %i[show update destroy]

  # GET /lists
  def index
    @lists = List.all
    render json: @lists
  end

  # GET /lists/1
  def show
    render json: @list
  end

  # POST /lists
  def create
    @list = List.new(list_params)
    if @list.save
      render json: @list, status: :created, location: list_url(@list)
    else
      render json: @list.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /lists/1
  def update
    if @list.update(list_params)
      render json: @list
    else
      render json: @list.errors, status: :unprocessable_entity
    end
  end

  # DELETE /lists/1
  def destroy
    @list.destroy
    render json: { message: 'List was successfully destroyed.' }
  end

  private

  def set_list
    @list = List.find(params[:id])
  end

  def list_params
    params.require(:list).permit(:name)
  end

  def check_list_existence
    return if List.exists?(params[:id])

    render json: { error: 'List not found' }, status: :not_found
  end
end
