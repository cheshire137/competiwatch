require 'test_helper'

class LoginControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

  setup do
    Rails.cache.clear
  end

  test 'loads successfully' do
    get '/'

    assert_response :ok
  end

  test 'redirects to match history for latest season when signed in' do
    oauth_account = create(:oauth_account)

    sign_in_as(oauth_account)
    get '/'

    assert_redirected_to matches_path(Season.latest_number, oauth_account)
  end
end
