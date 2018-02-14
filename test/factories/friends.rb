FactoryGirl.define do
  factory :friend do
    user { match.oauth_account.user }
    name { "Rob #{match.friends.count}" }
  end
end
