require 'test_helper'

class OauthAccountTest < ActiveSupport::TestCase
  test "can_be_unlinked? returns true when it is not the user's only account" do
    user = create(:user)
    oauth_account1 = create(:oauth_account, user: user)
    oauth_account2 = create(:oauth_account, user: user)

    assert_predicate oauth_account1, :can_be_unlinked?
    assert_predicate oauth_account2, :can_be_unlinked?
  end

  test "can_be_unlinked? returns false when it is the user's only account" do
    user = create(:user)
    oauth_account = create(:oauth_account, user: user)

    refute_predicate oauth_account, :can_be_unlinked?
  end

  test "default? returns true when it is the user's default OAuth account" do
    oauth_account = create(:oauth_account)
    oauth_account.user.default_oauth_account = oauth_account

    assert_predicate oauth_account, :default?
  end

  test "default? returns false when it is not the user's default OAuth account" do
    oauth_account = create(:oauth_account)

    refute_predicate oauth_account, :default?
  end

  test 'requires battletag' do
    oauth_account = OauthAccount.new

    refute_predicate oauth_account, :valid?
    assert_includes oauth_account.errors.messages[:battletag], "can't be blank"
  end

  test 'deletes matches when deleted' do
    oauth_account = create(:oauth_account)
    match1 = create(:match, oauth_account: oauth_account)
    match2 = create(:match, oauth_account: oauth_account)

    assert_difference 'Match.count', -2 do
      oauth_account.destroy
    end

    refute Match.exists?(match1.id)
    refute Match.exists?(match2.id)
  end

  test 'requires provider' do
    oauth_account = OauthAccount.new

    refute_predicate oauth_account, :valid?
    assert_includes oauth_account.errors.messages[:provider], "can't be blank"
  end

  test 'requires unique uid + provider' do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = OauthAccount.new(uid: oauth_account1.uid,
                                      provider: oauth_account1.provider)

    refute_predicate oauth_account2, :valid?
    assert_includes oauth_account2.errors.messages[:uid], 'has already been taken'
  end
end
