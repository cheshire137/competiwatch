require 'test_helper'

class MatchesHelperTest < ActionView::TestCase
  test 'returns darker green for bigger SR change' do
    match1 = build(:match, rank: 3573, placement: true, result: :loss)
    match2 = build(:match, rank: 3547, prior_match: match1, result: :loss)
    match3 = build(:match, rank: 3572, prior_match: match2, result: :win)
    match4 = build(:match, rank: 3596, prior_match: match3, result: :win)
    matches = [match1, match2, match3, match4]

    match3_style = match_rank_change_style(match3, matches)
    assert_equal 'background-color: rgb(102, 189, 125)', match3_style

    match4_style = match_rank_change_style(match4, matches)
    assert_equal 'background-color: rgb(152, 204, 129)', match4_style
  end

  test 'does not calculate rank change from penultimate to last placement match' do
    oauth_account = create(:oauth_account)
    penultimate_match = create(:match, oauth_account: oauth_account, result: :win,
                               placement: true, rank: nil)
    last_placement_match = create(:match, oauth_account: oauth_account, rank: 2540,
                                  prior_match: penultimate_match)

    actual = match_rank_change(last_placement_match, [penultimate_match, last_placement_match])

    assert_equal '--', actual
  end

  test 'does calculate rank change from last placement match to first non-placement match' do
    oauth_account = create(:oauth_account)
    last_placement_match = create(:match, oauth_account: oauth_account, rank: 2540,
                                  placement: true)
    first_non_placement_match = create(:match, oauth_account: oauth_account, rank: 2560,
                                       prior_match: last_placement_match)

    actual = match_rank_change(first_non_placement_match,
                               [last_placement_match, first_non_placement_match])

    assert_equal 20, actual
  end
end
