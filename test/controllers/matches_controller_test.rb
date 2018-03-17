require 'test_helper'

class MatchesControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

  setup do
    @past_season = seasons(:one)
    @season = seasons(:two)
    @future_season = create(:season, started_on: 4.months.from_now)
  end

  test 'redirects to profile when season is not visible for anonymous user' do
    account = create(:account)

    get "/season/#{@season}/#{account.to_param}"

    assert_redirected_to profile_path(account)
  end

  test 'redirects to profile when season is not visible for authenticated user' do
    account = create(:account)
    other_account = create(:account)

    sign_in_as(other_account)
    get "/season/#{@season}/#{account.to_param}"

    assert_redirected_to profile_path(account)
  end

  test 'index page loads successfully for the user who owns the account' do
    account = create(:account)
    create(:match, account: account, season: @season.number)
    assert_predicate @season, :active?

    sign_in_as(account)
    get "/season/#{@season}/#{account.to_param}"

    assert_response :ok
    assert_select '.matches-table'
    assert_select '.blankslate', false
    assert_equal true, assigns(:can_edit)
    assert_select "form[action='/season/#{@season}/#{account.to_param}']"
  end

  test 'index page loads successfully for past season for account owner' do
    user = create(:user)
    friend = create(:friend, user: user)
    account = create(:account, user: user)
    match = create(:match, account: account, season: @past_season.number)
    create(:match_friend, match: match, friend: friend)

    sign_in_as(account)
    get "/season/#{@past_season}/#{account.to_param}"

    assert_response :ok
  end

  test 'index page has future season message when no matches' do
    account = create(:account)

    sign_in_as(account)
    get "/season/#{@future_season}/#{account.to_param}"

    assert_select '.blankslate', text: /Season #{@future_season} has not started yet./
    assert_select '.flash-error',
      text: /You are logging a match for a competitive season that hasn't started yet./
  end

  test 'index page has past season message when no matches' do
    account = create(:account)

    sign_in_as(account)
    get "/season/#{@past_season}/#{account.to_param}"

    assert_select '.blankslate',
      text: /#{account}\s+did not log\s+any competitive matches in season #{@past_season}./
  end

  test 'index page has current season message when no matches' do
    account = create(:account)

    sign_in_as(account)
    get "/season/#{@season}/#{account.to_param}"

    assert_select '.blankslate',
      text: /#{account}\s+has not logged\s+any competitive matches in season #{@season}./
  end

  test 'index page loads successfully for other user when season is shared' do
    account = create(:account)
    other_account = create(:account)
    create(:match, account: account, season: @season.number)
    create(:season_share, season: @season.number, account: account)

    sign_in_as(other_account)
    get "/season/#{@season}/#{account.to_param}"

    assert_response :ok
    assert_equal false, assigns(:can_edit)
    assert_select '.js-match-filter'
  end

  test 'index page loads successfully for anonymous user when season is shared' do
    account = create(:account)
    create(:match, account: account, season: @season.number)
    create(:season_share, season: @season.number, account: account)

    get "/season/#{@season}/#{account.to_param}"

    assert_response :ok
    assert_equal false, assigns(:can_edit)
    assert_select '.js-match-filter'
  end

  test "won't let you log a match for another user's account" do
    account1 = create(:account)
    account2 = create(:account)

    assert_no_difference 'Match.count' do
      sign_in_as(account1)
      post "/season/#{@season}/#{account2.to_param}", params: { match: { rank: 2500 } }
    end

    assert_response :not_found
  end

  test "won't let you log a match for another user's account via specifying account ID" do
    account1 = create(:account)
    account2 = create(:account)

    assert_difference 'account1.matches.count' do
      assert_no_difference 'account2.matches.count' do
        sign_in_as(account1)
        post "/season/#{@season}/#{account1.to_param}", params: {
          match: { rank: 2500, account_id: account2.id }
        }
      end
    end

    match = account1.matches.last
    refute_nil match
    assert_redirected_to matches_path(@season, account1, anchor: "match-row-#{match.id}")
  end

  test "redirects to profile when you try to view unshared match history for another user's account" do
    account1 = create(:account)
    account2 = create(:account)

    sign_in_as(account1)
    get "/season/#{@season}/#{account2.to_param}"

    assert_redirected_to profile_path(account2)
  end

  test 'will not log a new match when last match by user was too recent' do
    user = create(:user)
    account1 = create(:account, user: user)
    account2 = create(:account, user: user)
    recent_match = create(:match, account: account1, created_at: 1.minute.ago)

    assert_no_difference 'Match.count' do
      sign_in_as(account2)
      post "/season/#{@season}/#{account2.to_param}", params: { match: { rank: 2500 } }
    end

    assert_equal 'You are logging matches too frequently.', flash[:error]
    assert_redirected_to matches_path(@season, account2)
  end

  test 'logs a match' do
    account = create(:account)

    assert_difference 'account.matches.count' do
      sign_in_as(account)
      post "/season/#{@season}/#{account.to_param}", params: { match: { rank: 2500 } }
    end

    match = account.matches.ordered_by_time.last
    refute_nil match
    assert_redirected_to matches_path(@season, account, anchor: "match-row-#{match.id}")
  end

  test 'logs a match for owner of account when season is shared' do
    user = create(:user)
    account1 = create(:account, user: user)
    account2 = create(:account, user: user)
    create(:season_share, account: account1, season: @season.number)

    assert_difference 'account1.matches.in_season(@season).count' do
      sign_in_as(account2)
      post "/season/#{@season}/#{account1.to_param}", params: { match: { rank: 2500 } }
    end

    match = account1.matches.ordered_by_time.last
    refute_nil match
    assert_redirected_to matches_path(@season, account1, anchor: "match-row-#{match.id}")
  end

  test 'renders edit form when create fails' do
    account = create(:account)

    assert_no_difference 'Match.count' do
      sign_in_as(account)
      post "/season/#{@season}/#{account.to_param}", params: {
        match: { rank: @season.max_rank + 1 }
      }
    end

    assert_response :ok
    assert_select '.flash-error', text: /Rank must be less than or equal to #{Match::MAX_RANK}/
    assert_select "form[action='/season/#{@season}/#{account.to_param}'][method='post']"
    assert_select 'input[name="_method"][value="put"]', false
  end

  test 'shows error message when too many friends are given on create' do
    account = create(:account)

    assert_no_difference 'Match.count' do
      sign_in_as(account)
      post "/season/#{@season}/#{account.to_param}", params: {
        match: { rank: 2500 }, friend_names: %w[A B C D E F]
      }
    end

    assert_response :ok

    text = /Cannot have more than #{Match::MAX_FRIENDS_PER_MATCH} other players in your group/
    assert_select '.flash-error', text: text
  end

  test 'can delete your own match' do
    account = create(:account)
    match = create(:match, account: account, season: @season.number)

    assert_difference 'Match.count', -1 do
      sign_in_as(account)
      delete "/matches/#{match.id}"
    end

    assert_equal "Successfully deleted #{account}'s match.", flash[:notice]
    assert_redirected_to matches_path(@season, account)
    refute Match.exists?(match.id)
  end

  test "cannot delete someone else's match" do
    account1 = create(:account)
    account2 = create(:account)
    match = create(:match, account: account1)

    assert_no_difference 'Match.count' do
      sign_in_as(account2)
      delete "/matches/#{match.id}"
    end

    assert_response :not_found
  end

  test 'can update your own match' do
    user = create(:user)
    account1 = create(:account, user: user)
    account2 = create(:account, user: user)
    match = create(:match, account: account1)
    map = create(:map)

    sign_in_as(account1)
    put "/matches/#{match.id}", params: {
      match: { rank: 1234, map_id: map.id, account_id: account2.id }
    }

    assert_redirected_to matches_path(match.season, account2, anchor: "match-row-#{match.id}")
    assert_equal map, match.reload.map
    assert_equal 1234, match.rank
    assert_equal account2, match.account
  end

  test 'cannot update match account to an account that is not yours' do
    account1 = create(:account)
    account2 = create(:account)
    match = create(:match, account: account1)

    sign_in_as(account1)
    put "/matches/#{match.id}", params: {
      match: { rank: 1234, account_id: account2.id }
    }

    assert_response :ok
    assert_equal account1, match.reload.account
    assert_equal 'Invalid account.', flash[:error]
  end

  test 'renders edit page when update fails' do
    user = create(:user)
    account1 = create(:account, user: user)
    account2 = create(:account, user: user)
    match = create(:match, account: account1, season: @season.number)
    map = create(:map)

    sign_in_as(account1)
    put "/matches/#{match.id}", params: {
      match: { rank: Match::MAX_RANK + 1, map_id: map.id, account_id: account2.id }
    }

    assert_response :ok
    assert_select '.flash-error', text: /Rank must be less than or equal to #{@season.max_rank}/
    assert_select "option[value='#{account1.id}']", text: account1.battletag
    assert_select "option[value='#{account2.id}']", text: account2.battletag
    assert_select "form[action='/matches/#{match.id}'][method='post']"
    assert_select 'input[name="_method"][value="put"]'
  end

  test 'renders edit page when too many friends are chosen' do
    account = create(:account)
    match = create(:match, account: account, season: @season.number)
    map = create(:map)

    sign_in_as(account)
    put "/matches/#{match.id}", params: { match: { rank: 1234 }, friend_names: %w[A B C D E F] }

    assert_response :ok

    text = /Cannot have more than #{Match::MAX_FRIENDS_PER_MATCH} other players in your group/
    assert_select '.flash-error', text: text
  end

  test "cannot update another user's match" do
    account1 = create(:account)
    account2 = create(:account)
    match = create(:match, account: account1, rank: 3234, season: @season.number)

    sign_in_as(account2)
    put "/matches/#{match.id}", params: { match: { rank: 1234 } }

    assert_response :not_found
    assert_equal 3234, match.reload.rank
  end

  test 'edit page loads for your account and non-placement match' do
    account = create(:account)
    prior_match = create(:match, account: account, season: @season.number)
    match = create(:match, account: account, placement: false,
                   prior_match: prior_match, season: @season.number)
    refute match.placement?
    refute match.placement_log?

    sign_in_as(account)
    get "/matches/#{@season}/#{account.to_param}/#{match.id}"

    assert_response :ok
    assert_select "form#delete-match[action='/matches/#{match.id}']"
    assert_select "form#edit-match[action='/matches/#{match.id}']"
  end

  test 'edit page loads for your account and placement log match' do
    account = create(:account)
    match = create(:match, account: account, map: nil,
                   placement: false, prior_match: nil, season: @season.number)
    refute match.placement?
    assert match.placement_log?

    sign_in_as(account)
    get "/matches/#{@season}/#{account.to_param}/#{match.id}"

    assert_response :ok
    assert_select "form#delete-match[action='/matches/#{match.id}']"
    assert_select "form#edit-placement-log-match[action='/matches/#{match.id}']"
  end

  test 'edit page loads for your account and placement match' do
    account = create(:account)
    match = create(:match, account: account, placement: true, season: @season.number)
    assert match.placement?
    refute match.placement_log?

    sign_in_as(account)
    get "/matches/#{@season}/#{account.to_param}/#{match.id}"

    assert_response :ok
    assert_select "form#delete-match[action='/matches/#{match.id}']"
    assert_select "form#edit-placement-match[action='/matches/#{match.id}']"
  end

  test "edit page 404s for another user's account and match" do
    account1 = create(:account)
    account2 = create(:account)
    match = create(:match, account: account1, season: @season.number)

    sign_in_as(account2)
    get "/matches/#{@season}/#{account1.to_param}/#{match.id}"

    assert_response :not_found
  end
end
