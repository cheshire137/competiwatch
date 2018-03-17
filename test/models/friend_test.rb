require 'test_helper'

class FriendTest < ActiveSupport::TestCase
  test 'requires name' do
    friend = Friend.new

    refute_predicate friend, :valid?
    assert_includes friend.errors.messages[:name], "can't be blank"
  end

  test 'validates name length' do
    name = 'a' * (Friend::MAX_NAME_LENGTH + 1)
    friend = Friend.new(name: name)

    refute_predicate friend, :valid?
    assert_includes friend.errors.messages[:name],
      "is too long (maximum is #{Friend::MAX_NAME_LENGTH} characters)"
  end

  test 'requires user' do
    friend = Friend.new

    refute_predicate friend, :valid?
    assert_includes friend.errors.messages[:user], 'must exist'
  end

  test 'updates matches when friend is deleted' do
    user = create(:user)
    account = create(:account, user: user)
    friend1 = create(:friend, user: user)
    friend2 = create(:friend, user: user)
    match1 = create(:match, account: account, group_member_ids: [friend1.id])
    match2 = create(:match, account: account, group_member_ids: [friend1.id, friend2.id])

    friend1.destroy!

    assert_empty match1.reload.group_member_ids
    assert_equal [friend2.id], match2.reload.group_member_ids
  end
end
