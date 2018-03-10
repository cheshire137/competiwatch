require 'test_helper'

class AccountHeroTest < ActiveSupport::TestCase
  test 'requires seconds_played >= 0' do
    account_hero = AccountHero.new(seconds_played: -1)

    refute_predicate account_hero, :valid?
    assert_includes account_hero.errors.messages[:seconds_played], 'must be greater than or equal to 0'
  end
end
