FactoryGirl.define do
  factory :match_friend do
    match
    user { match.oauth_account.user }
    name { "Rob #{match.friends.count}" }
  end
end
