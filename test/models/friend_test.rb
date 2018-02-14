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
end
