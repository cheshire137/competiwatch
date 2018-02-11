class CreateMatchFriends < ActiveRecord::Migration[5.1]
  def change
    create_table :match_friends do |t|
      t.string :friend, null: false, limit: 30
      t.integer :match_id, null: false
      t.integer :user_id, null: false
    end
    add_index :match_friends, [:match_id, :friend], unique: true
    add_index :match_friends, :user_id
  end
end
