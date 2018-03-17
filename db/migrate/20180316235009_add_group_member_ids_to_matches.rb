class AddGroupMemberIdsToMatches < ActiveRecord::Migration[5.1]
  def up
    add_column :matches, :group_member_ids, :integer, array: true, default: [], null: false

    execute <<-SQL
      UPDATE matches SET group_member_ids = friend_ids
      FROM (
        SELECT match_id, ARRAY_AGG(friend_id ORDER BY friend_id) AS friend_ids
        FROM match_friends
        GROUP BY match_id
      ) AS match_friends
      WHERE match_friends.match_id = matches.id
    SQL
  end

  def down
    remove_column :matches, :group_member_ids
  end
end
