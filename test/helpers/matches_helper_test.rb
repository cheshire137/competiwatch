require 'test_helper'

class MatchesHelperTest < ActionView::TestCase
  test 'returns darker green for bigger SR gain' do
    match1 = build(:match, rank: 3573, placement: true, result: :loss)
    match2 = build(:match, rank: 3547, prior_match: match1, result: :loss) # -26
    match3 = build(:match, rank: 3572, prior_match: match2, result: :win)  # +25
    match4 = build(:match, rank: 3596, prior_match: match3, result: :win)  # +24
    matches = [match1, match2, match3, match4]

    match3_style = match_rank_change_style(match3, matches)
    assert_equal 'background-color: rgb(102, 189, 125)', match3_style

    match4_style = match_rank_change_style(match4, matches)
    assert_equal 'background-color: rgb(178, 212, 132)', match4_style
  end

  test 'returns darker red for bigger SR loss' do
    match1 = build(:match, rank: 4016, result: :loss)
    match2 = build(:match, rank: 3993, result: :loss, prior_match: match1) # -23
    match3 = build(:match, rank: 3966, result: :loss, prior_match: match2) # -27
    matches = [match1, match2, match3]

    match2_style = match_rank_change_style(match2, matches)
    assert_equal 'background-color: rgb(250, 170, 124)', match2_style

    match3_style = match_rank_change_style(match3, matches)
    assert_equal 'background-color: rgb(246, 106, 110)', match3_style
  end

  test 'does not calculate rank change from penultimate to last placement match' do
    account = create(:account)
    penultimate_match = create(:match, account: account, result: :win,
                               placement: true, rank: nil)
    last_placement_match = create(:match, account: account, rank: 2540,
                                  prior_match: penultimate_match)

    actual = match_rank_change(last_placement_match, [penultimate_match, last_placement_match])

    assert_equal '--', actual
  end

  test 'does calculate rank change from last placement match to first non-placement match' do
    account = create(:account)
    last_placement_match = create(:match, account: account, rank: 2540,
                                  placement: true)
    first_non_placement_match = create(:match, account: account, rank: 2560,
                                       prior_match: last_placement_match)

    actual = match_rank_change(first_non_placement_match,
                               [last_placement_match, first_non_placement_match])

    assert_equal 20, actual
  end
end
