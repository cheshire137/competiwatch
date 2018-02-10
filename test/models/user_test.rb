require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'requires battletag' do
    user = User.new

    refute_predicate user, :valid?
    assert_includes user.errors.messages[:battletag], "can't be blank"
  end

  test 'requires unique battletag' do
    user1 = create(:user)
    user2 = User.new(battletag: user1.battletag)

    refute_predicate user2, :valid?
    assert_includes user2.errors.messages[:battletag], 'has already been taken'
  end
end
