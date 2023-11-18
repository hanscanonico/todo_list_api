# frozen_string_literal: true

class SetDefaultForDoneInTasks < ActiveRecord::Migration[7.1]
  def change
    change_column_default :tasks, :done, from: nil, to: false
  end
end
