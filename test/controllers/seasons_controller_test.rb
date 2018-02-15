require 'test_helper'

class SeasonsControllerTest < ActionDispatch::IntegrationTest
  test 'index page redirects anonymous user' do
    get '/seasons/DPSMain22-1234'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'index page loads successfully for authenticated user' do
    oauth_account = create(:oauth_account)

    sign_in_as(oauth_account)
    get "/seasons/#{oauth_account.to_param}"

    assert_response :ok
  end

  test "won't let you view all season data for another user's account" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)

    sign_in_as(oauth_account1)
    get "/seasons/#{oauth_account2.to_param}"

    assert_response :not_found
  end
end
