require 'test_helper'

class SetAccountHeroesJobTest < ActiveJob::TestCase
  fixtures :heroes

  test 'creates new account heroes for given account' do
    account = create(:account, battletag: 'cheshire137#1695')

    assert_difference 'account.account_heroes.count', 5 do
      VCR.use_cassette('ow_api_stats') do
        SetAccountHeroesJob.perform_now(account.id)
      end
    end

    account_hero_names = account.account_heroes.ordered_by_playtime.includes(:hero).
      map { |account_hero| account_hero.hero.name}
    assert_equal ['Mercy', 'Zenyatta', 'Moira', 'Lúcio', 'Orisa'],
      account_hero_names
  end
end
