FactoryGirl.define do
  factory :match_friend do
    match
    friend { create(:friend, user: match.oauth_account.user) }
  end
end
