class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.boolean :done, null: false, default: false

      t.timestamps
    end
  end
end
