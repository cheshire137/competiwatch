# encoding: UTF-8
require 'test_helper'

class HeroTest < ActiveSupport::TestCase
  fixtures :heroes

  test 'most_played returns a hash of the heroes and match counts' do
    account = create(:account)
    other_account = create(:account)
    match1 = create(:match, account: account)
    match1.heroes << heroes(:ana)
    match1.heroes << heroes(:mercy)
    match2 = create(:match, account: account)
    match2.heroes << heroes(:ana)
    match2.heroes << heroes(:mercy)
    match3 = create(:match, account: account)
    match3.heroes << heroes(:mccree)
    other_match = create(:match, account: other_account)
    other_match.heroes << heroes(:mccree)

    expected = { heroes(:ana) => 2, heroes(:mercy) => 2, heroes(:mccree) => 2 }
    assert_equal expected, Hero.most_played
  end

  test 'requires name' do
    hero = Hero.new

    refute_predicate hero, :valid?
    assert_includes hero.errors.messages[:name], "can't be blank"
  end

  test 'requires unique name' do
    hero1 = heroes(:mercy)
    hero2 = Hero.new(name: hero1.name)

    refute_predicate hero2, :valid?
    assert_includes hero2.errors.messages[:name], 'has already been taken'
  end

  test 'requires role' do
    hero = Hero.new

    refute_predicate hero, :valid?
    assert_includes hero.errors.messages[:role], "can't be blank"
  end

  test 'requires valid role' do
    hero = Hero.new(role: 'something invalid')

    refute_predicate hero, :valid?
    assert_includes hero.errors.messages[:role], 'is not included in the list'
  end

  test 'flatten_name removes accented characters and symbols, converts aliases' do
    assert_equal 'lucio', Hero.flatten_name('Lúcio')
    assert_equal 'dva', Hero.flatten_name('D.Va')
    assert_equal 'soldier76', Hero.flatten_name('Soldier: 76')
    assert_equal 'soldier76', Hero.flatten_name('Soldier')
    assert_equal 'mercy', Hero.flatten_name('mErCy')
    assert_equal 'torbjorn', Hero.flatten_name('Torb')
    assert_equal 'junkrat', Hero.flatten_name('junk')
    assert_equal 'widowmaker', Hero.flatten_name('Widow')
    assert_equal 'symmetra', Hero.flatten_name('Sym')
  end
end
