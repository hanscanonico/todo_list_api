class AddOmniauthToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :provider
      t.datetime :uid
    end
  end
end
