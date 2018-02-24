require 'test_helper'

class SeasonTest < ActiveSupport::TestCase
  fixtures :seasons

  test 'active? returns true for started-but-not-yet-ended season' do
    season = build(:season, started_on: 1.week.ago)

    assert_predicate season, :active?
  end

  test 'past? returns true for season that has ended' do
    season = build(:season, ended_on: 1.week.ago)

    assert_predicate season, :past?
  end

  test 'future? returns true for season that has not yet started' do
    season = build(:season, started_on: 1.week.from_now)

    assert_predicate season, :future?
  end

  test 'future? returns false when season has started' do
    season = build(:season, started_on: 1.day.ago)

    refute_predicate season, :future?
  end

  test 'current_number returns active season' do
    past_season = seasons(:two)
    present_season = seasons(:two)
    future_season = create(:season, started_on: 1.month.from_now, ended_on: 2.months.from_now)

    assert_equal present_season.number, Season.current_number
  end

  test 'latest_number returns highest season number' do
    assert_equal seasons(:two).number, Season.latest_number
  end

  test 'to_s returns number' do
    season = seasons(:two)

    assert_equal '2', season.to_s
  end

  test 'to_param returns number' do
    season = seasons(:two)

    assert_equal '2', season.to_param
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

  test 'requires started_on to be greater than previous season ended_on' do
    past_season = seasons(:two)
    past_season.ended_on = 1.day.ago
    past_season.save!
    new_season = build(:season, started_on: past_season.ended_on - 1.week)

    refute_predicate new_season, :valid?
    assert_includes new_season.errors.messages[:started_on],
      "must be on or later than #{past_season.ended_on}"
  end
end
