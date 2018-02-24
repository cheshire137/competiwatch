FactoryBot.define do
  factory :match do
    oauth_account
    map
    rank 2500
    season 7
    after(:create) do |match|
      Season.find_by_number(match.season) || create(:season, number: match.season)
    end
  end
end
