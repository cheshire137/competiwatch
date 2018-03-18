class DropMatchFriends < ActiveRecord::Migration[5.1]
  def up
    drop_table :match_friends
  end

  def down
    create_table "match_friends" do |t|
      t.integer "match_id", null: false
      t.integer "friend_id", null: false
      t.index ["match_id", "friend_id"], name: "index_match_friends_on_match_id_and_friend_id", unique: true
    end
  end
end
