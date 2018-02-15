FactoryBot.define do
  factory :friend do
    user
    name { "Rob #{user.friends.count}" }
  end
end
