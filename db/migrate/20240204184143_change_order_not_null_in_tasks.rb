# frozen_string_literal: true

# db/migrate/[timestamp]_change_order_not_null_in_tasks.rb
class ChangeOrderNotNullInTasks < ActiveRecord::Migration[7.1]
  def change
    change_column_null :tasks, :order, false
  end
end
