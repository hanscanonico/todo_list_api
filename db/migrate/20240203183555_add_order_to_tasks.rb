# frozen_string_literal: true

class AddOrderToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :order, :integer
  end
end
