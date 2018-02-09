FactoryGirl.define do
  factory :map do
    name { "Hanamura#{Map.count}" }
    map_type 'assault'
    color '#ff00ff'
  end
end
