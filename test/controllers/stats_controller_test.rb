require 'test_helper'

class StatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @oauth_account = create(:oauth_account)
  end

  test 'stats page redirects anonymous user' do
    get '/stats'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'all seasons page redirects anonymous user' do
    get "/stats/all-seasons/#{@oauth_account.to_param}"

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'all accounts page redirects anonymous user' do
    get '/stats/all-accounts/2'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'stats page loads successfully for authenticated user with no matches' do
    sign_in_as(@oauth_account)
    get '/stats'

    assert_response :ok
    assert_select 'div', text: /Matches logged:\s+0/
  end

  test 'all seasons page loads successfully for authenticated user with no matches' do
    sign_in_as(@oauth_account)
    get "/stats/all-seasons/#{@oauth_account.to_param}"

    assert_response :ok
    assert_select 'div', text: /Matches logged:\s+0/
  end

  test 'all accounts page loads successfully for authenticated user with no matches' do
    sign_in_as(@oauth_account)
    get '/stats/all-accounts/4'

    assert_response :ok
    assert_select 'div', text: /Matches logged:\s+0/
  end

  test 'stats page loads successfully for authenticated user with matches' do
    oauth_account2 = create(:oauth_account, user: @oauth_account.user)
    create(:match, oauth_account: @oauth_account, season: 1, result: :win)
    create(:match, oauth_account: oauth_account2, season: 2, result: :loss)
    create(:match, oauth_account: @oauth_account, season: 3, result: :draw)

    sign_in_as(@oauth_account)
    get '/stats'

    assert_response :ok
    assert_select 'div', text: /Matches logged:\s+3/
    assert_select 'div', text: /Active in seasons:\s+1, 2, 3/
    assert_select 'div', text: /2\s+accounts with matches/
  end

  test 'all seasons page loads successfully for authenticated user with matches' do
    create(:match, oauth_account: @oauth_account, season: 1, result: :win)
    create(:match, oauth_account: @oauth_account, season: 2, result: :loss)
    create(:match, oauth_account: @oauth_account, season: 3, result: :draw)

    sign_in_as(@oauth_account)
    get "/stats/all-seasons/#{@oauth_account.to_param}"

    assert_response :ok
    assert_select 'div', text: /Matches logged:\s+3/
    assert_select 'div', text: /Active in seasons:\s+1, 2, 3/
  end

  test 'all accounts page loads successfully for authenticated user with matches' do
    oauth_account2 = create(:oauth_account, user: @oauth_account.user)
    create(:match, oauth_account: @oauth_account, season: 2, result: :win)
    create(:match, oauth_account: oauth_account2, season: 2, result: :loss)
    create(:match, oauth_account: @oauth_account, season: 2, result: :draw)

    sign_in_as(@oauth_account)
    get '/stats/all-accounts/2'

    assert_response :ok
    assert_select 'div', text: /Matches logged:\s+3/
    assert_select 'div', text: /2\s+accounts with matches/
  end

  test "won't let you view all season data for another user's account" do
    oauth_account2 = create(:oauth_account)

    sign_in_as(@oauth_account)
    get "/stats/all-seasons/#{oauth_account2.to_param}"

    assert_response :not_found
  end
end
