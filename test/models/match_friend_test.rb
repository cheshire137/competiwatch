require 'test_helper'

class MatchFriendTest < ActiveSupport::TestCase
  test 'requires friend' do
    match_friend = MatchFriend.new

    refute_predicate match_friend, :valid?
    assert_includes match_friend.errors.messages[:friend], "can't be blank"
  end

  test 'requires unique friend + match' do
    match_friend1 = create(:match_friend)
    match_friend = MatchFriend.new(match_id: match_friend1.match_id, friend: match_friend1.friend)

    refute_predicate match_friend, :valid?
    assert_includes match_friend.errors.messages[:friend], 'has already been taken'
  end
end
