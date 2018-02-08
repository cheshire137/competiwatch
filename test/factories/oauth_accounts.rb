FactoryGirl.define do
  factory :oauth_account do
    user
    provider 'bnet'
    uid { "12345#{OauthAccount.count}" }
    battletag { user.battletag }
  end
end
