# frozen_string_literal: true

class AddOrderToLists < ActiveRecord::Migration[7.1]
  def change
    add_column :lists, :order, :integer
  end
end
