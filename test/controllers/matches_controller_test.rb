require 'test_helper'

class MatchesControllerTest < ActionDispatch::IntegrationTest
  test 'index page redirects anonymous user' do
    get '/season/1/DPSMain22#1234'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'index page loads successfully for authenticated user' do
    oauth_account = create(:oauth_account)

    sign_in_as(oauth_account)
    get "/season/1/#{oauth_account.to_param}"

    assert_response :ok
  end

  test "cannot export another user's season" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)

    sign_in_as(oauth_account1)
    post "/season/5/#{oauth_account2.to_param}/export.csv"

    assert_response :not_found
  end

  test 'can export your own season' do
    oauth_account = create(:oauth_account)

    sign_in_as(oauth_account)
    post "/season/5/#{oauth_account.to_param}/export.csv"

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

    assert_redirected_to matches_path(1, oauth_account)
  end

  test 'can update your own match' do
    oauth_account = create(:oauth_account)
    match = create(:match, oauth_account: oauth_account)
    map = create(:map)

    sign_in_as(oauth_account)
    put "/matches/#{match.id}", params: { match: { rank: 1234, map_id: map.id } }

    assert_redirected_to matches_path(match.season, oauth_account)
    assert_equal map, match.reload.map
    assert_equal 1234, match.rank
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

  test 'edit page loads for your account and match' do
    oauth_account = create(:oauth_account)
    match = create(:match, oauth_account: oauth_account)

    sign_in_as(oauth_account)
    get "/matches/#{match.id}"

    assert_response :ok
  end

  test "edit page 404s for another user's account and match" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)
    match = create(:match, oauth_account: oauth_account1)

    sign_in_as(oauth_account2)
    get "/matches/#{match.id}"

    assert_response :not_found
  end

  test 'can wipe your own season' do
    oauth_account = create(:oauth_account)
    season = 3
    match1 = create(:match, oauth_account: oauth_account, season: season)
    match2 = create(:match, oauth_account: oauth_account, season: season)
    match3 = create(:match, oauth_account: oauth_account, season: season + 1)
    match4 = create(:match, season: season)

    assert_difference 'Match.count', -2 do
      sign_in_as(oauth_account)
      delete "/season/#{season}/#{oauth_account.to_param}"
    end

    assert_redirected_to matches_path(Match::LATEST_SEASON, oauth_account)
    refute Match.exists?(match1.id)
    refute Match.exists?(match2.id)
    assert Match.exists?(match3.id), 'should not delete my match from another season'
    assert Match.exists?(match4.id), "should not delete another account's match"
  end

  test "cannot wipe another user's season" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)
    season = 5
    match1 = create(:match, oauth_account: oauth_account1, season: season)
    match2 = create(:match, oauth_account: oauth_account1, season: season)

    assert_no_difference 'Match.count' do
      sign_in_as(oauth_account2)
      delete "/season/#{season}/#{oauth_account1.to_param}"
    end

    assert_response :not_found
  end

  test "cannot list seasons to wipe for another user's account" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)

    sign_in_as(oauth_account2)
    get "/matches/confirm-wipe/#{oauth_account1.to_param}"

    assert_response :not_found
  end

  test 'can list seasons to wipe in your account' do
    oauth_account = create(:oauth_account)

    sign_in_as(oauth_account)
    get "/matches/confirm-wipe/#{oauth_account.to_param}"

    assert_response :ok
  end

  test "cannot confirm wiping another user's season" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)

    sign_in_as(oauth_account2)
    get "/season/4/#{oauth_account1.to_param}/confirm-wipe"

    assert_response :not_found
  end

  test 'can confirm wiping my season' do
    oauth_account = create(:oauth_account)

    sign_in_as(oauth_account)
    get "/season/4/#{oauth_account.to_param}/confirm-wipe"

    assert_response :ok
  end
end
