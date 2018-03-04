FactoryBot.define do
  factory :oauth_account do
    user
    provider 'bnet'
    uid { "12345#{OAuthAccount.count}" }
    battletag do
      if user
        "#{user.battletag}#{user.oauth_accounts.count}"
      else
        "SomeAccount#123#{OAuthAccount.count}"
      end
    end
  end
end
