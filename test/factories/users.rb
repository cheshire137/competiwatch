FactoryBot.define do
  factory :user do
    battletag { "SomeUser#123#{User.count}" }
  end
end
