require 'test_helper'

class TrendsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @oauth_account = create(:oauth_account, user: @user)
    @match1 = create(:match, oauth_account: @oauth_account, season: 2)
    @match2 = create(:match, oauth_account: @oauth_account, season: 2,
                     prior_match: @match1)
    @friend = create(:friend, user: @user)
    @match1_friend = create(:match_friend, match: @match1, friend: @friend)
    @match2_friend = create(:match_friend, match: @match2, friend: @friend)
  end

  test 'heroes chart 404s for anonymous user when season not shared' do
    get "/trends/2/#{@oauth_account.to_param}/heroes-chart"

    assert_response :not_found
  end

  test 'heroes chart loads for owner' do
    sign_in_as(@oauth_account)
    get "/trends/2/#{@oauth_account.to_param}/heroes-chart"

    assert_response :ok
  end

  test 'heroes chart loads for anonymous user when season is shared' do
    create(:season_share, oauth_account: @oauth_account, season: 2)

    get "/trends/2/#{@oauth_account.to_param}/heroes-chart"

    assert_response :ok
  end

  test 'thrower/leaver chart 404s for anonymous user when season not shared' do
    get "/trends/2/#{@oauth_account.to_param}/thrower-leaver-chart"

    assert_response :not_found
  end

  test 'thrower/leaver chart loads for owner' do
    sign_in_as(@oauth_account)
    get "/trends/2/#{@oauth_account.to_param}/thrower-leaver-chart"

    assert_response :ok
  end

  test 'thrower/leaver chart loads for anonymous user when season is shared' do
    create(:season_share, oauth_account: @oauth_account, season: 2)

    get "/trends/2/#{@oauth_account.to_param}/thrower-leaver-chart"

    assert_response :ok
  end

  test 'streaks chart 404s for anonymous user when season not shared' do
    get "/trends/2/#{@oauth_account.to_param}/streaks-chart"

    assert_response :not_found
  end

  test 'streaks chart loads for owner' do
    sign_in_as(@oauth_account)
    get "/trends/2/#{@oauth_account.to_param}/streaks-chart"

    assert_response :ok
  end

  test 'streaks chart loads for anonymous user when season is shared' do
    create(:season_share, oauth_account: @oauth_account, season: 2)

    get "/trends/2/#{@oauth_account.to_param}/streaks-chart"

    assert_response :ok
  end

  test 'map chart 404s for anonymous user when season not shared' do
    get "/trends/2/#{@oauth_account.to_param}/map-chart"

    assert_response :not_found
  end

  test 'map chart loads for owner' do
    sign_in_as(@oauth_account)
    get "/trends/2/#{@oauth_account.to_param}/map-chart"

    assert_response :ok
  end

  test 'map chart loads for anonymous user when season is shared' do
    create(:season_share, oauth_account: @oauth_account, season: 2)

    get "/trends/2/#{@oauth_account.to_param}/map-chart"

    assert_response :ok
  end

  test 'index page 404s for anonymous user when season not shared' do
    get "/trends/2/#{@oauth_account.to_param}"

    assert_response :not_found
  end

  test 'index page loads for owner' do
    sign_in_as(@oauth_account)
    get "/trends/2/#{@oauth_account.to_param}"

    assert_response :ok
  end

  test 'index page loads for anonymous user when season is shared' do
    create(:season_share, oauth_account: @oauth_account, season: 2)

    get "/trends/2/#{@oauth_account.to_param}"

    assert_response :ok
  end

  test 'index page loads for a user who is not the owner when season is shared' do
    create(:season_share, oauth_account: @oauth_account, season: 2)
    other_account = create(:oauth_account)

    sign_in_as(other_account)
    get "/trends/2/#{@oauth_account.to_param}"

    assert_response :ok
  end

  test 'group size chart 404s for anonymous user when season not shared' do
    get "/trends/2/#{@oauth_account.to_param}/group-size-chart"

    assert_response :not_found
  end

  test 'group size chart loads for owner' do
    sign_in_as(@oauth_account)
    get "/trends/2/#{@oauth_account.to_param}/group-size-chart"

    assert_response :ok
  end

  test 'group size chart loads for anonymous user when season is shared' do
    create(:season_share, oauth_account: @oauth_account, season: 2)

    get "/trends/2/#{@oauth_account.to_param}/group-size-chart"

    assert_response :ok
  end

  test 'role chart 404s for anonymous user when season not shared' do
    get "/trends/2/#{@oauth_account.to_param}/role-chart"

    assert_response :not_found
  end

  test 'role chart loads for owner' do
    sign_in_as(@oauth_account)
    get "/trends/2/#{@oauth_account.to_param}/role-chart"

    assert_response :ok
  end

  test 'role chart loads for anonymous user when season is shared' do
    create(:season_share, oauth_account: @oauth_account, season: 2)

    get "/trends/2/#{@oauth_account.to_param}/role-chart"

    assert_response :ok
  end
end
