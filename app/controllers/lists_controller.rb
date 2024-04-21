# frozen_string_literal: true

class ListsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :authenticate_user!
  before_action :check_list_existence, only: %i[show update destroy switch_order]
  before_action :set_list, only: %i[show update destroy switch_order]

  # GET /lists
  def index
    @lists = current_user.lists.order(:order)
    render json: @lists
  end

  # GET /lists/id
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

  # PATCH/PUT /lists/id
  def update
    if @list.update(list_params)
      render json: @list
    else
      render json: @list.errors, status: :unprocessable_entity
    end
  end

  # DELETE /lists/id
  def destroy
    @list.destroy
    render json: { message: 'List was successfully destroyed.' }
  end

  # PATCH /lists/id/switch_order
  def switch_order
    list1 = current_user.lists.find(params[:id])
    list2 = current_user.lists.find(params[:id2])

    list1_order = list1.order
    list1.update(order: list2.order)
    list2.update(order: list1_order)

    render json: { message: 'Lists order were successfully switched.' }
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
