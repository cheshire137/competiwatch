require 'test_helper'

class LoginControllerTest < ActionDispatch::IntegrationTest
  test 'loads successfully' do
    get '/'

    assert_response :ok
  end

  test 'redirects to match history for latest season when signed in' do
    oauth_account = create(:oauth_account)
    create(:season)

    sign_in_as(oauth_account)
    get '/'

    assert_redirected_to matches_path(Season.latest_number, oauth_account)
  end
end
