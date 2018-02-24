require 'test_helper'

class MatchesControllerTest < ActionDispatch::IntegrationTest
  test 'index page 404s for anonymous user when season is not visible' do
    oauth_account = create(:oauth_account)

    get "/season/1/#{oauth_account.to_param}"

    assert_response :not_found
  end

  test 'index page 404s for authenticated user when season is not visible' do
    oauth_account = create(:oauth_account)
    other_account = create(:oauth_account)

    sign_in_as(other_account)
    get "/season/1/#{oauth_account.to_param}"

    assert_response :not_found
  end

  test 'index page loads successfully for the user who owns the account' do
    oauth_account = create(:oauth_account)

    sign_in_as(oauth_account)
    get "/season/1/#{oauth_account.to_param}"

    assert_response :ok
    assert_select "form[action='/season/1/#{oauth_account.to_param}']"
  end

  test 'index page loads successfully for other user when season is shared' do
    oauth_account = create(:oauth_account)
    other_account = create(:oauth_account)
    season = 1
    create(:season_share, season: season, oauth_account: oauth_account)

    sign_in_as(other_account)
    get "/season/#{season}/#{oauth_account.to_param}"

    assert_response :ok
  end

  test "won't let you log a match for another user's account" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)

    sign_in_as(oauth_account1)
    post "/season/1/#{oauth_account2.to_param}", params: { match: { rank: 2500 } }

    assert_response :not_found
  end

  test "won't let you view match history for another user's account" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)

    sign_in_as(oauth_account1)
    get "/season/1/#{oauth_account2.to_param}"

    assert_response :not_found
  end

  test 'logs a match' do
    oauth_account = create(:oauth_account)

    assert_difference 'oauth_account.matches.count' do
      sign_in_as(oauth_account)
      post "/season/1/#{oauth_account.to_param}", params: { match: { rank: 2500 } }
    end

    match = oauth_account.matches.ordered_by_time.last
    refute_nil match
    assert_redirected_to matches_path(1, oauth_account, anchor: "match-row-#{match.id}")
  end

  test 'logs a match for owner of account when season is shared' do
    user = create(:user)
    oauth_account1 = create(:oauth_account, user: user)
    oauth_account2 = create(:oauth_account, user: user)
    season = 8
    create(:season_share, oauth_account: oauth_account1, season: season)

    assert_difference 'oauth_account1.matches.in_season(season).count' do
      sign_in_as(oauth_account2)
      post "/season/#{season}/#{oauth_account1.to_param}", params: { match: { rank: 2500 } }
    end

    match = oauth_account1.matches.ordered_by_time.last
    refute_nil match
    assert_redirected_to matches_path(season, oauth_account1, anchor: "match-row-#{match.id}")
  end

  test 'renders edit form when create fails' do
    oauth_account = create(:oauth_account)

    assert_no_difference 'Match.count' do
      sign_in_as(oauth_account)
      post "/season/1/#{oauth_account.to_param}", params: {
        match: { rank: Match::MAX_RANK + 1 }
      }
    end

    assert_response :ok
    assert_select '.flash-error', text: /Rank must be less than or equal to #{Match::MAX_RANK}/
  end

  test 'shows error message when too many friends are given on create' do
    oauth_account = create(:oauth_account)

    assert_no_difference 'Match.count' do
      sign_in_as(oauth_account)
      post "/season/1/#{oauth_account.to_param}", params: {
        match: { rank: 2500 }, friend_names: %w[A B C D E F]
      }
    end

    assert_response :ok

    text = /Cannot have more than #{MatchFriend::MAX_FRIENDS_PER_MATCH} other players in your group/
    assert_select '.flash-error', text: text
  end

  test 'can delete your own match' do
    oauth_account = create(:oauth_account)
    match = create(:match, oauth_account: oauth_account)

    assert_difference 'Match.count', -1 do
      sign_in_as(oauth_account)
      delete "/matches/#{match.id}"
    end

    assert_equal "Successfully deleted #{oauth_account}'s match.", flash[:notice]
    assert_redirected_to matches_path(match.season, oauth_account)
    refute Match.exists?(match.id)
  end

  test "cannot delete someone else's match" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)
    match = create(:match, oauth_account: oauth_account1)

    assert_no_difference 'Match.count' do
      sign_in_as(oauth_account2)
      delete "/matches/#{match.id}"
    end

    assert_response :not_found
  end

  test 'can update your own match' do
    oauth_account = create(:oauth_account)
    match = create(:match, oauth_account: oauth_account)
    map = create(:map)

    sign_in_as(oauth_account)
    put "/matches/#{match.id}", params: { match: { rank: 1234, map_id: map.id } }

    assert_redirected_to matches_path(match.season, oauth_account, anchor: "match-row-#{match.id}")
    assert_equal map, match.reload.map
    assert_equal 1234, match.rank
  end

  test 'renders edit page when update fails' do
    oauth_account = create(:oauth_account)
    match = create(:match, oauth_account: oauth_account)
    map = create(:map)

    sign_in_as(oauth_account)
    put "/matches/#{match.id}", params: { match: { rank: Match::MAX_RANK + 1, map_id: map.id } }

    assert_response :ok
    assert_select '.flash-error', text: /Rank must be less than or equal to #{Match::MAX_RANK}/
  end

  test 'renders edit page when too many friends are chosen' do
    oauth_account = create(:oauth_account)
    match = create(:match, oauth_account: oauth_account)
    map = create(:map)

    sign_in_as(oauth_account)
    put "/matches/#{match.id}", params: { match: { rank: 1234 }, friend_names: %w[A B C D E F] }

    assert_response :ok

    text = /Cannot have more than #{MatchFriend::MAX_FRIENDS_PER_MATCH} other players in your group/
    assert_select '.flash-error', text: text
  end

  test "cannot update another user's match" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)
    match = create(:match, oauth_account: oauth_account1, rank: 3234)

    sign_in_as(oauth_account2)
    put "/matches/#{match.id}", params: { match: { rank: 1234 } }

    assert_response :not_found
    assert_equal 3234, match.reload.rank
  end

  test 'edit page loads for your account and non-placement match' do
    oauth_account = create(:oauth_account)
    prior_match = create(:match, oauth_account: oauth_account)
    match = create(:match, oauth_account: oauth_account, placement: false,
                   prior_match: prior_match)
    refute match.placement?
    refute match.placement_log?

    sign_in_as(oauth_account)
    get "/matches/#{match.season}/#{oauth_account.to_param}/#{match.id}"

    assert_response :ok
    assert_select "form#delete-match[action='/matches/#{match.id}']"
    assert_select "form#edit-match[action='/matches/#{match.id}']"
  end

  test 'edit page loads for your account and placement log match' do
    oauth_account = create(:oauth_account)
    match = create(:match, oauth_account: oauth_account, map: nil,
                   placement: false, prior_match: nil)
    refute match.placement?
    assert match.placement_log?

    sign_in_as(oauth_account)
    get "/matches/#{match.season}/#{oauth_account.to_param}/#{match.id}"

    assert_response :ok
    assert_select "form#delete-match[action='/matches/#{match.id}']"
    assert_select "form#edit-match[action='/matches/#{match.id}']"
  end

  test 'edit page loads for your account and placement match' do
    oauth_account = create(:oauth_account)
    match = create(:match, oauth_account: oauth_account, placement: true)
    assert match.placement?
    refute match.placement_log?

    sign_in_as(oauth_account)
    get "/matches/#{match.season}/#{oauth_account.to_param}/#{match.id}"

    assert_response :ok
    assert_select "form#delete-match[action='/matches/#{match.id}']"
    assert_select "form#edit-match[action='/matches/#{match.id}']"
  end

  test "edit page 404s for another user's account and match" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)
    match = create(:match, oauth_account: oauth_account1)

    sign_in_as(oauth_account2)
    get "/matches/#{match.season}/#{oauth_account1.to_param}/#{match.id}"

    assert_response :not_found
  end
end
