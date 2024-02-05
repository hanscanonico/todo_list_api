# frozen_string_literal: true

class AddOrderToTasksAndLists < ActiveRecord::Migration[7.1]
  def up
    List.order(:created_at).each_with_index do |list, list_index|
      list.update_column(:order, list_index + 1)
      list.tasks.order(:created_at).each_with_index do |task, task_index|
        task.update_column(:order, task_index + 1)
      end
    end
  end

  def down
    Task.update_all(order: nil)
    List.update_all(order: nil)
  end
end
