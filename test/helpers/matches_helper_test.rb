class MatchesHelperTest < ActionView::TestCase
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
