require 'test_helper'

class OauthAccountTest < ActiveSupport::TestCase
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
