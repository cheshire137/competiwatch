FactoryBot.define do
  factory :oauth_account do
    user
    provider 'bnet'
    uid { "12345#{OauthAccount.count}" }
    battletag do
      if user
        "#{user.battletag}#{user.oauth_accounts.count}"
      else
        "SomeAccount#123#{OauthAccount.count}"
      end
    end
  end
end
