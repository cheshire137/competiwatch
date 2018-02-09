require 'test_helper'

class MatchesControllerTest < ActionDispatch::IntegrationTest
  test 'redirects anonymous user' do
    get '/season/1/DPSMain22#1234'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'loads successfully for authenticated user' do
    oauth_account = create(:oauth_account)
    sign_in_as(oauth_account)

    get "/season/1/#{oauth_account.to_param}"

    assert_response :ok
  end
end
