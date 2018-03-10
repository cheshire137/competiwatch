require 'test_helper'

class MatchFriendTest < ActiveSupport::TestCase
  test 'deletes friend after last match association is removed' do
    user = create(:user)
    account = create(:account, user: user)
    friend = create(:friend, user: user)
    match_friend1 = create(:match_friend, friend: friend, account: account)
    match_friend2 = create(:match_friend, friend: friend, account: account)

    assert_no_difference('Friend.count') { match_friend2.destroy }
    assert_difference('Friend.count', -1) { match_friend1.destroy }

    refute Friend.exists?(friend.id)
  end

  test 'disallows more than 5 others in your match group' do
    user = create(:user)
    account = create(:account, user: user)
    match = create(:match, account: account)
    friends = []
    5.times { |i| friends << create(:friend, name: "Friend#{i}", user: user) }
    match_friend1 = create(:match_friend, match: match, friend: friends[0])
    match_friend2 = create(:match_friend, match: match, friend: friends[1])
    match_friend3 = create(:match_friend, match: match, friend: friends[2])
    match_friend4 = create(:match_friend, match: match, friend: friends[3])
    match_friend5 = create(:match_friend, match: match, friend: friends[4])
    match_friend6 = MatchFriend.new(match: match)

    refute_predicate match_friend6, :valid?
    assert_includes match_friend6.errors.messages[:match],
      'already has a full group: you, Friend0, Friend1, Friend2, Friend3, Friend4'
  end

  test 'requires unique friend + match' do
    match_friend1 = create(:match_friend)
    match_friend = MatchFriend.new(match_id: match_friend1.match_id,
                                   friend_id: match_friend1.friend_id)

    refute_predicate match_friend, :valid?
    assert_includes match_friend.errors.messages[:friend_id], 'has already been taken'
  end

  test 'requires friend' do
    match_friend = MatchFriend.new

    refute_predicate match_friend, :valid?
    assert_includes match_friend.errors.messages[:friend], 'must exist'
  end

  test 'requires friend user to match account user' do
    friend = create(:friend)
    match = create(:match)
    match_friend = MatchFriend.new(friend: friend, match: match)

    refute_predicate match_friend, :valid?
    assert_includes match_friend.errors.messages[:friend],
      "must be a friend of the owner of account #{match.account}"
  end
end
