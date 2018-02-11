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

  test 'validates friend length' do
    friend = 'a' * (MatchFriend::MAX_FRIEND_LENGTH + 1)
    match_friend = MatchFriend.new(friend: friend)

    refute_predicate match_friend, :valid?
    assert_includes match_friend.errors.messages[:friend],
      "is too long (maximum is #{MatchFriend::MAX_FRIEND_LENGTH} characters)"
  end

  test 'requires user' do
    match_friend = MatchFriend.new

    refute_predicate match_friend, :valid?
    assert_includes match_friend.errors.messages[:user], 'must exist'
  end

  test 'requires user to match account user' do
    user = create(:user)
    match = create(:match)
    match_friend = MatchFriend.new(user: user, match: match)

    refute_predicate match_friend, :valid?
    assert_includes match_friend.errors.messages[:user],
      "must be the owner of account #{match.oauth_account}"
  end
end
