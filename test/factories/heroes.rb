FactoryBot.define do
  factory :hero do
    name { "Superhero#{Hero.count}" }
    role 'healer'
  end
end
