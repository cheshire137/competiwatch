FactoryGirl.define do
  factory :match_friend do
    match
    friend { "Rob #{match.friends.count}" }
  end
end
