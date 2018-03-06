require 'test_helper'

class TrendsControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons, :heroes

  setup do
    @past_season = seasons(:one)
    @season = seasons(:two)
    @future_season = create(:season, started_on: 2.months.from_now)
    @user = create(:user)
    @oauth_account = create(:oauth_account, user: @user)
    @hero1 = heroes(:brigitte)
    @hero2 = heroes(:genji)
    @match1 = create(:match, oauth_account: @oauth_account, season: @season.number,
                     result: :win)
    @match1.heroes << @hero1
    @match2 = create(:match, oauth_account: @oauth_account, season: @season.number,
                     prior_match: @match1)
    @friend = create(:friend, user: @user)
    @match1_friend = create(:match_friend, match: @match1, friend: @friend)
    @match2_friend = create(:match_friend, match: @match2, friend: @friend)
    @match2.heroes << @hero2
  end

  test 'all seasons/accounts page redirects anonymous user' do
    get '/trends/all-seasons-accounts'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'all seasons page redirects anonymous user' do
    get "/trends/all-seasons/#{@oauth_account.to_param}"

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'all accounts page redirects anonymous user' do
    get '/trends/all-accounts/2'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'all seasons/accounts page loads successfully for authenticated user with no matches' do
    oauth_account = create(:oauth_account)

    sign_in_as(oauth_account)
    get '/trends/all-seasons-accounts'

    assert_response :ok
    assert_select 'div.mb-4', text: /Matches logged:\s+0/
  end

  test 'all seasons page loads successfully for authenticated user with no matches' do
    oauth_account = create(:oauth_account)

    sign_in_as(oauth_account)
    get "/trends/all-seasons/#{oauth_account.to_param}"

    assert_response :ok
    assert_select 'div', text: /Matches logged:\s+0/
  end

  test 'all accounts page loads successfully for authenticated user with no matches' do
    oauth_account = create(:oauth_account)
    season = seasons(:two)

    sign_in_as(oauth_account)
    get "/trends/all-accounts/#{season}"

    assert_response :ok
    assert_select 'div', text: /Matches logged:\s+0/
  end

  test 'all seasons/accounts page loads successfully for authenticated user with matches' do
    oauth_account2 = create(:oauth_account, user: @user)
    create(:match, oauth_account: @oauth_account, season: @past_season.number, result: :win)
    create(:match, oauth_account: oauth_account2, season: @past_season.number, result: :loss)

    sign_in_as(oauth_account2)
    get '/trends/all-seasons-accounts'

    assert_response :ok
    assert_select 'div.mb-4', text: /Matches logged:\s+4/
    assert_select 'div.mb-4', text: /Active in seasons:\s+#{@past_season}, #{@season}/
    assert_select 'div', text: /2\s+accounts with matches/
  end

  test 'all seasons page loads successfully for authenticated user with matches' do
    create(:match, oauth_account: @oauth_account, season: @past_season.number, result: :win)

    sign_in_as(@oauth_account)
    get "/trends/all-seasons/#{@oauth_account.to_param}"

    assert_response :ok
    assert_select 'div.mb-4', text: /Matches logged:\s+3/
    assert_select 'div', text: /Active in seasons:\s+#{@past_season}, #{@season}/
  end

  test 'all accounts page loads successfully for authenticated user with matches' do
    oauth_account2 = create(:oauth_account, user: @user)
    create(:match, oauth_account: @oauth_account, season: @past_season.number, result: :win)
    create(:match, oauth_account: oauth_account2, season: @past_season.number, result: :loss)
    create(:match, oauth_account: @oauth_account, season: @past_season.number, result: :draw)

    sign_in_as(@oauth_account)
    get "/trends/all-accounts/#{@past_season}"

    assert_response :ok
    assert_select 'div.mb-4', text: /Matches logged:\s+3/
    assert_select 'div', text: /2\s+accounts with matches/
  end

  test "won't let you view all season data for another user's account" do
    oauth_account2 = create(:oauth_account)

    sign_in_as(@oauth_account)
    get "/trends/all-seasons/#{oauth_account2.to_param}"

    assert_response :not_found
  end

  test 'says season has not started for future season' do
    sign_in_as(@oauth_account)
    get "/trends/#{@future_season}/#{@oauth_account.to_param}"

    assert_select '.blankslate', text: /Season #{@future_season} has not started yet./
  end

  test 'says when user has not logged matches in past season' do
    sign_in_as(@oauth_account)
    get "/trends/#{@past_season}/#{@oauth_account.to_param}"

    assert_select '.blankslate',
      text: /#{@oauth_account}\s+did not log\s+any competitive matches in season #{@past_season}./
  end

  test 'index page 404s for anonymous user when season not shared' do
    get "/trends/#{@season}/#{@oauth_account.to_param}"

    assert_response :not_found
  end

  test 'index page loads for owner' do
    sign_in_as(@oauth_account)
    get "/trends/#{@season}/#{@oauth_account.to_param}"

    assert_response :ok
  end

  test 'index page loads for anonymous user when season is shared' do
    create(:season_share, oauth_account: @oauth_account, season: @season.number)

    get "/trends/#{@season}/#{@oauth_account.to_param}"

    assert_response :ok
  end

  test 'index page loads for a user who is not the owner when season is shared' do
    create(:season_share, oauth_account: @oauth_account, season: @season.number)
    other_account = create(:oauth_account)

    sign_in_as(other_account)
    get "/trends/#{@season}/#{@oauth_account.to_param}"

    assert_response :ok
  end
end
