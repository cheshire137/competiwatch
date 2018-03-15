FactoryBot.define do
  factory :account do
    user
    provider 'bnet'
    uid { "12345#{Account.count}" }
    battletag do
      if user
        "#{user.battletag}#{user.accounts.count}"
      else
        "SomeAccount#123#{Account.count}"
      end
    end
  end
end
