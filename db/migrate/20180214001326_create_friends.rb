class CreateFriends < ActiveRecord::Migration[5.1]
  def up
    create_table :friends do |t|
      t.string :name, null: false, limit: 30
      t.integer :user_id, null: false
    end
    add_index :friends, [:user_id, :name], unique: true

    execute "INSERT INTO friends (name, user_id) " \
            "SELECT name, user_id FROM match_friends ON CONFLICT DO NOTHING"
  end

  def down
    drop_table :friends
  end
end
