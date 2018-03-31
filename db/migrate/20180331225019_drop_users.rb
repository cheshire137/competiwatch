class DropUsers < ActiveRecord::Migration[5.1]
  def up
    remove_column :accounts, :user_id
    drop_table :users
  end

  def down
    create_table "users" do |t|
      t.string "battletag", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["battletag"], name: "index_users_on_battletag", unique: true
    end

    add_column :accounts, :user_id, :integer
    add_index :accounts, :user_id
  end
end
