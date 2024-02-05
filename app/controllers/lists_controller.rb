# frozen_string_literal: true

class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_list_existence, only: %i[show update destroy]
  before_action :set_list, only: %i[show update destroy]

  # GET /lists
  def index
    @lists = current_user.lists
    render json: @lists
  end

  # GET /lists/1
  def show
    render json: @list
  end

  # POST /lists
  def create
    @list = current_user.lists.new(list_params)
    last_list_order = current_user.lists.maximum(:order)
    @list.order = last_list_order ? last_list_order + 1 : 1
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
    @list = current_user.lists.find(params[:id])
  end

  def list_params
    params.require(:list).permit(:name)
  end

  def check_list_existence
    return if current_user.lists.exists?(params[:id])

    render json: { error: 'List not found' }, status: :not_found
  end
end
