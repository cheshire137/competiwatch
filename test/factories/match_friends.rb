FactoryBot.define do
  factory :match_friend do
    match
    friend { create(:friend, user: match.account.user) }
  end
end
