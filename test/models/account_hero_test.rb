require 'test_helper'

class AccountHeroTest < ActiveSupport::TestCase
  fixtures :heroes

  test 'requires seconds_played >= 0' do
    account_hero = AccountHero.new(seconds_played: -1)

    refute_predicate account_hero, :valid?
    assert_includes account_hero.errors.messages[:seconds_played], 'must be greater than or equal to 0'
  end

  test 'disallows more than 5 heroes per account' do
    account = create(:account)
    create(:account_hero, account: account, hero: heroes(:symmetra))
    create(:account_hero, account: account, hero: heroes(:mercy))
    create(:account_hero, account: account, hero: heroes(:zenyatta))
    create(:account_hero, account: account, hero: heroes(:mccree))
    create(:account_hero, account: account, hero: heroes(:reinhardt))

    account_hero = AccountHero.new(account: account, hero: heroes(:ana))

    refute_predicate account_hero, :valid?
    assert_includes account_hero.errors.messages[:account],
      'already has as many top heroes as is allowed per account'
  end
end
