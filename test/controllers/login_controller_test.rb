require 'test_helper'

class LoginControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

  setup do
    Rails.cache.delete(Season::LATEST_SEASON_CACHE_KEY)
  end

  test 'side-wide message not shown to anonymous users' do
    ENV['AUTH_SITEWIDE_MESSAGE'] = 'hello world'

    get '/'

    assert_response :ok
    assert_select '.flash-warn', false
  end

  test 'loads successfully' do
    get '/'

    assert_response :ok
  end

  test 'redirects to match history for latest season when signed in' do
    account = create(:account)

    sign_in_as(account)
    get '/'

    assert_redirected_to matches_path(Season.latest_number, account)
  end
end
