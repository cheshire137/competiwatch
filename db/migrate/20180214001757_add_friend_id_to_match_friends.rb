class AddFriendIdToMatchFriends < ActiveRecord::Migration[5.1]
  def up
    add_column :match_friends, :friend_id, :integer

    execute <<-SQL
      UPDATE match_friends SET friend_id = friends.id
      FROM (SELECT id, name, user_id FROM friends) AS friends
      WHERE friends.name = match_friends.name
      AND friends.user_id = match_friends.user_id
    SQL

    remove_column :match_friends, :user_id
    remove_column :match_friends, :name

    change_column_null :match_friends, :friend_id, false

    add_index :match_friends, [:match_id, :friend_id], unique: true
  end

  def down
    add_column :match_friends, :name, :string, limit: 30
    add_column :match_friends, :user_id, :integer

    execute <<-SQL
      UPDATE match_friends SET name = friends.name, user_id = friends.user_id
      FROM (SELECT id, name, user_id FROM friends) AS friends
      WHERE friends.id = friend_id
    SQL

    change_column_null :match_friends, :name, false
    change_column_null :match_friends, :user_id, false

    add_index :match_friends, [:match_id, :name], unique: true

    remove_column :match_friends, :friend_id
  end
end
