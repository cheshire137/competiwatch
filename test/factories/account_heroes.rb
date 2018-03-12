FactoryBot.define do
  factory :account_hero do
    account
    hero
    seconds_played { rand(1000) }
  end
end
