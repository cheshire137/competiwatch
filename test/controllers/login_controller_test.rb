require 'test_helper'

class LoginControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

  setup do
    Rails.cache.delete(Season::LATEST_SEASON_CACHE_KEY)
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
