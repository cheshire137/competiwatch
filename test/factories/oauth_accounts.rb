FactoryBot.define do
  factory :oauth_account do
    user
    provider 'bnet'
    uid { "12345#{OauthAccount.count}" }
    battletag { user ? user.battletag : "SomeAccount#123#{OauthAccount.count}" }
  end
end
