FactoryBot.define do
  factory :season_share do
    oauth_account
    season 1
    after(:create) do |season_share|
      Season.find_by_number(season_share.season) || create(:season, number: season_share.season)
    end
  end
end
