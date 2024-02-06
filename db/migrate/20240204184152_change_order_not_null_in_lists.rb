# frozen_string_literal: true

class ChangeOrderNotNullInLists < ActiveRecord::Migration[7.1]
  def change
    change_column_null :lists, :order, false
  end
end
