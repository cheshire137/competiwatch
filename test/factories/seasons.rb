FactoryBot.define do
  factory :season do
    number { (Season.latest_number || 0) + 1 }
    max_rank 5000
  end
end
