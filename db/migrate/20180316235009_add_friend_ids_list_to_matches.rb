class AddFriendIdsListToMatches < ActiveRecord::Migration[5.1]
  def up
    add_column :matches, :friend_ids_list, :integer, array: true

    execute <<-SQL
      UPDATE matches SET friend_ids_list = friend_ids
      FROM (
        SELECT match_id, ARRAY_AGG(friend_id) AS friend_ids
        FROM match_friends
        GROUP BY match_id
      ) AS match_friends
      WHERE match_friends.match_id = matches.id
    SQL
  end

  def down
    remove_column :matches, :friend_ids_list
  end
end
