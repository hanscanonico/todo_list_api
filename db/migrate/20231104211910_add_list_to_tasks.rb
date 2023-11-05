class AddListToTasks < ActiveRecord::Migration[7.1]
  def change
    add_reference :tasks, :list, null: false, foreign_key: true
  end
end
