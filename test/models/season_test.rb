require 'test_helper'

class SeasonTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
  end

  test 'active? returns true for started-but-not-yet-ended season' do
    season = create(:season, started_on: 1.week.ago)

    assert_predicate season, :active?
  end

  test 'past? returns true for season that has ended' do
    season = create(:season, ended_on: 1.week.ago)

    assert_predicate season, :past?
  end

  test 'future? returns true for season that has not yet started' do
    season = create(:season, started_on: 1.week.from_now)

    assert_predicate season, :future?
  end

  test 'future? returns false when season has started' do
    season = create(:season, started_on: 1.day.ago)

    refute_predicate season, :future?
  end

  test 'current_number returns active season' do
    past_season = create(:season, started_on: 1.year.ago, ended_on: 11.months.ago)
    present_season = create(:season, started_on: 1.month.ago, ended_on: 1.week.from_now)
    future_season = create(:season, started_on: 1.month.from_now, ended_on: 2.months.from_now)

    assert_equal present_season.number, Season.current_number
  end

  test 'latest_number returns highest season number' do
    create(:season, number: 1)
    create(:season, number: 3)
    create(:season, number: 2)

    assert_equal 3, Season.latest_number
  end

  test 'to_s returns number' do
    season = create(:season, number: 4)

    assert_equal '4', season.to_s
  end

  test 'to_param returns number' do
    season = create(:season, number: 5)

    assert_equal '5', season.to_param
  end

  test 'requires number' do
    season = Season.new

    refute_predicate season, :valid?
    assert_includes season.errors.messages[:number], "can't be blank"
  end

  test 'requires positive number' do
    season = Season.new(number: -1)

    refute_predicate season, :valid?
    assert_includes season.errors.messages[:number], 'must be greater than 0'
  end

  test 'requires integer number' do
    season = Season.new(number: 3.5)

    refute_predicate season, :valid?
    assert_includes season.errors.messages[:number], 'must be an integer'
  end

  test 'requires positive max_rank' do
    season = Season.new(max_rank: -1)

    refute_predicate season, :valid?
    assert_includes season.errors.messages[:max_rank], 'must be greater than 0'
  end

  test 'requires integer max_rank' do
    season = Season.new(max_rank: 3500.3)

    refute_predicate season, :valid?
    assert_includes season.errors.messages[:max_rank], 'must be an integer'
  end
end
