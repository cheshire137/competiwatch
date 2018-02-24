FactoryBot.define do
  factory :season do
    number { (Season.latest_number || 0) + 1 }
    max_rank 5000
    after(:build) do |season|
      if season.ended_on && season.started_on.nil?
        season.started_on = season.ended_on - 3.months
      end
    end
  end
end
