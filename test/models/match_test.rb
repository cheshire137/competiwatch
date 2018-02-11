require 'test_helper'

class MatchTest < ActiveSupport::TestCase
  test 'requires season' do
    match = Match.new

    refute_predicate match, :valid?
    assert_includes match.errors.messages[:season], "can't be blank"
  end

  test 'deletes friends when deleted' do
    match = create(:match)
    match_friend1 = create(:match_friend, match: match)
    match_friend2 = create(:match_friend, match: match)

    assert_difference 'MatchFriend.count', -2 do
      match.destroy
    end

    refute MatchFriend.exists?(match_friend1.id)
    refute MatchFriend.exists?(match_friend2.id)
  end

  test 'requires valid season' do
    match = Match.new(season: 0)

    refute_predicate match, :valid?
    assert_includes match.errors.messages[:season], 'must be greater than or equal to 1'
  end

  test 'requires rank if not a placement match' do
    match = Match.new(placement: false)

    refute_predicate match, :valid?
    assert_includes match.errors.messages[:rank], 'is required if not a placement match'
  end

  test 'sets result at validation time based on rank and prior match rank' do
    prior_match = create(:match, rank: 1234)
    match = Match.new(rank: 1254, prior_match: prior_match)

    match.valid?

    assert_equal :win, match.result
  end

  test 'requires season to be the same as prior match season' do
    prior_match = create(:match)
    match = Match.new(season: prior_match.season + 1, prior_match: prior_match)

    refute_predicate match, :valid?
    assert_includes match.errors.messages[:season], 'must be the same as season from prior match'
  end

  test 'requires rank <= max rank' do
    match = Match.new(rank: Match::MAX_RANK + 1)

    refute_predicate match, :valid?
    assert_includes match.errors.messages[:rank], "must be less than or equal to #{Match::MAX_RANK}"
  end

  test 'requires rank >= 0' do
    match = Match.new(rank: -1)

    refute_predicate match, :valid?
    assert_includes match.errors.messages[:rank], 'must be greater than or equal to 0'
  end
end
