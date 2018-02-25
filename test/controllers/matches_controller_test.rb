require 'test_helper'

class MatchesControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

  setup do
    @past_season = seasons(:one)
    @season = seasons(:two)
    @future_season = create(:season, started_on: 4.months.from_now)
  end

  test 'index page 404s for anonymous user when season is not visible' do
    oauth_account = create(:oauth_account)

    get "/season/#{@season}/#{oauth_account.to_param}"

    assert_response :not_found
  end

  test 'index page 404s for authenticated user when season is not visible' do
    oauth_account = create(:oauth_account)
    other_account = create(:oauth_account)

    sign_in_as(other_account)
    get "/season/#{@season}/#{oauth_account.to_param}"

    assert_response :not_found
  end

  test 'index page loads successfully for the user who owns the account' do
    oauth_account = create(:oauth_account)
    create(:match, oauth_account: oauth_account, season: @season.number)
    assert_predicate @season, :active?

    sign_in_as(oauth_account)
    get "/season/#{@season}/#{oauth_account.to_param}"

    assert_response :ok
    assert_select '.matches-table'
    assert_select '.blankslate', false
    assert_select "form[action='/season/#{@season}/#{oauth_account.to_param}']"
  end

  test 'index page has future season message when no matches' do
    oauth_account = create(:oauth_account)

    sign_in_as(oauth_account)
    get "/season/#{@future_season}/#{oauth_account.to_param}"

    assert_select '.blankslate', text: /Season #{@future_season} has not started yet./
    assert_select '.flash-error',
      text: /You are logging a match for a competitive season that hasn't started yet./
  end

  test 'index page has past season message when no matches' do
    oauth_account = create(:oauth_account)

    sign_in_as(oauth_account)
    get "/season/#{@past_season}/#{oauth_account.to_param}"

    assert_select '.blankslate',
      text: /#{oauth_account} did not log any competitive matches in season #{@past_season}./
  end

  test 'index page loads successfully for other user when season is shared' do
    oauth_account = create(:oauth_account)
    other_account = create(:oauth_account)
    create(:match, oauth_account: oauth_account, season: @season.number)
    create(:season_share, season: @season.number, oauth_account: oauth_account)

    sign_in_as(other_account)
    get "/season/#{@season}/#{oauth_account.to_param}"

    assert_response :ok
    assert_select '.js-match-filter'
  end

  test 'index page loads successfully for anonymous user when season is shared' do
    oauth_account = create(:oauth_account)
    create(:match, oauth_account: oauth_account, season: @season.number)
    create(:season_share, season: @season.number, oauth_account: oauth_account)

    get "/season/#{@season}/#{oauth_account.to_param}"

    assert_response :ok
    assert_select '.js-match-filter'
  end

  test "won't let you log a match for another user's account" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)

    sign_in_as(oauth_account1)
    post "/season/#{@season}/#{oauth_account2.to_param}", params: { match: { rank: 2500 } }

    assert_response :not_found
  end

  test "won't let you view match history for another user's account" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)

    sign_in_as(oauth_account1)
    get "/season/#{@season}/#{oauth_account2.to_param}"

    assert_response :not_found
  end

  test 'logs a match' do
    oauth_account = create(:oauth_account)

    assert_difference 'oauth_account.matches.count' do
      sign_in_as(oauth_account)
      post "/season/#{@season}/#{oauth_account.to_param}", params: { match: { rank: 2500 } }
    end

    match = oauth_account.matches.ordered_by_time.last
    refute_nil match
    assert_redirected_to matches_path(@season, oauth_account, anchor: "match-row-#{match.id}")
  end

  test 'logs a match for owner of account when season is shared' do
    user = create(:user)
    oauth_account1 = create(:oauth_account, user: user)
    oauth_account2 = create(:oauth_account, user: user)
    create(:season_share, oauth_account: oauth_account1, season: @season.number)

    assert_difference 'oauth_account1.matches.in_season(@season).count' do
      sign_in_as(oauth_account2)
      post "/season/#{@season}/#{oauth_account1.to_param}", params: { match: { rank: 2500 } }
    end

    match = oauth_account1.matches.ordered_by_time.last
    refute_nil match
    assert_redirected_to matches_path(@season, oauth_account1, anchor: "match-row-#{match.id}")
  end

  test 'renders edit form when create fails' do
    oauth_account = create(:oauth_account)

    assert_no_difference 'Match.count' do
      sign_in_as(oauth_account)
      post "/season/#{@season}/#{oauth_account.to_param}", params: {
        match: { rank: @season.max_rank + 1 }
      }
    end

    assert_response :ok
    assert_select '.flash-error', text: /Rank must be less than or equal to #{Match::MAX_RANK}/
  end

  test 'shows error message when too many friends are given on create' do
    oauth_account = create(:oauth_account)

    assert_no_difference 'Match.count' do
      sign_in_as(oauth_account)
      post "/season/#{@season}/#{oauth_account.to_param}", params: {
        match: { rank: 2500 }, friend_names: %w[A B C D E F]
      }
    end

    assert_response :ok

    text = /Cannot have more than #{MatchFriend::MAX_FRIENDS_PER_MATCH} other players in your group/
    assert_select '.flash-error', text: text
  end

  test 'can delete your own match' do
    oauth_account = create(:oauth_account)
    match = create(:match, oauth_account: oauth_account, season: @season.number)

    assert_difference 'Match.count', -1 do
      sign_in_as(oauth_account)
      delete "/matches/#{match.id}"
    end

    assert_equal "Successfully deleted #{oauth_account}'s match.", flash[:notice]
    assert_redirected_to matches_path(@season, oauth_account)
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
    match = create(:match, oauth_account: oauth_account, season: @season.number)
    map = create(:map)

    sign_in_as(oauth_account)
    put "/matches/#{match.id}", params: { match: { rank: Match::MAX_RANK + 1, map_id: map.id } }

    assert_response :ok
    assert_select '.flash-error', text: /Rank must be less than or equal to #{@season.max_rank}/
  end

  test 'renders edit page when too many friends are chosen' do
    oauth_account = create(:oauth_account)
    match = create(:match, oauth_account: oauth_account, season: @season.number)
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
    match = create(:match, oauth_account: oauth_account1, rank: 3234, season: @season.number)

    sign_in_as(oauth_account2)
    put "/matches/#{match.id}", params: { match: { rank: 1234 } }

    assert_response :not_found
    assert_equal 3234, match.reload.rank
  end

  test 'edit page loads for your account and non-placement match' do
    oauth_account = create(:oauth_account)
    prior_match = create(:match, oauth_account: oauth_account, season: @season.number)
    match = create(:match, oauth_account: oauth_account, placement: false,
                   prior_match: prior_match, season: @season.number)
    refute match.placement?
    refute match.placement_log?

    sign_in_as(oauth_account)
    get "/matches/#{@season}/#{oauth_account.to_param}/#{match.id}"

    assert_response :ok
    assert_select "form#delete-match[action='/matches/#{match.id}']"
    assert_select "form#edit-match[action='/matches/#{match.id}']"
  end

  test 'edit page loads for your account and placement log match' do
    oauth_account = create(:oauth_account)
    match = create(:match, oauth_account: oauth_account, map: nil,
                   placement: false, prior_match: nil, season: @season.number)
    refute match.placement?
    assert match.placement_log?

    sign_in_as(oauth_account)
    get "/matches/#{@season}/#{oauth_account.to_param}/#{match.id}"

    assert_response :ok
    assert_select "form#delete-match[action='/matches/#{match.id}']"
    assert_select "form#edit-match[action='/matches/#{match.id}']"
  end

  test 'edit page loads for your account and placement match' do
    oauth_account = create(:oauth_account)
    match = create(:match, oauth_account: oauth_account, placement: true, season: @season.number)
    assert match.placement?
    refute match.placement_log?

    sign_in_as(oauth_account)
    get "/matches/#{@season}/#{oauth_account.to_param}/#{match.id}"

    assert_response :ok
    assert_select "form#delete-match[action='/matches/#{match.id}']"
    assert_select "form#edit-match[action='/matches/#{match.id}']"
  end

  test "edit page 404s for another user's account and match" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)
    match = create(:match, oauth_account: oauth_account1, season: @season.number)

    sign_in_as(oauth_account2)
    get "/matches/#{@season}/#{oauth_account1.to_param}/#{match.id}"

    assert_response :not_found
  end
end
