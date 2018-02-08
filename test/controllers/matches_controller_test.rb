require 'test_helper'

class MatchesControllerTest < ActionDispatch::IntegrationTest
  test 'redirects anonymous user' do
    get '/season/1/DPSMain22#1234'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'loads successfully for authenticated user' do
    user = create(:user)
    sign_in_as(user)

    get "/season/1/#{user.to_param}"

    assert_response :ok
  end
end
