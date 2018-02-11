require 'test_helper'

class MatchFriendTest < ActiveSupport::TestCase
  test 'requires name' do
    match_friend = MatchFriend.new

    refute_predicate match_friend, :valid?
    assert_includes match_friend.errors.messages[:name], "can't be blank"
  end

  test 'disallows more than 5 others in your match group' do
    match = create(:match)
    match_friend1 = create(:match_friend, match: match, name: 'Rob')
    match_friend2 = create(:match_friend, match: match, name: 'Zion')
    match_friend3 = create(:match_friend, match: match, name: 'Siege')
    match_friend4 = create(:match_friend, match: match, name: 'Bell')
    match_friend5 = create(:match_friend, match: match, name: 'Ptero')
    match_friend6 = MatchFriend.new(match: match)

    refute_predicate match_friend6, :valid?
    assert_includes match_friend6.errors.messages[:match],
      'already has a full group: you, Bell, Ptero, Rob, Siege, Zion'
  end

  test 'requires unique name + match' do
    match_friend1 = create(:match_friend)
    match_friend = MatchFriend.new(match_id: match_friend1.match_id, name: match_friend1.name)

    refute_predicate match_friend, :valid?
    assert_includes match_friend.errors.messages[:name], 'has already been taken'
  end

  test 'validates name length' do
    name = 'a' * (MatchFriend::MAX_NAME_LENGTH + 1)
    match_friend = MatchFriend.new(name: name)

    refute_predicate match_friend, :valid?
    assert_includes match_friend.errors.messages[:name],
      "is too long (maximum is #{MatchFriend::MAX_NAME_LENGTH} characters)"
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
