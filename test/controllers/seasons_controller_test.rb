require 'test_helper'

class SeasonsControllerTest < ActionDispatch::IntegrationTest
  test 'index page redirects anonymous user' do
    get '/seasons/DPSMain22-1234'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'index page loads successfully for authenticated user with no matches' do
    oauth_account = create(:oauth_account)

    sign_in_as(oauth_account)
    get "/seasons/#{oauth_account.to_param}"

    assert_response :ok
    assert_select 'div', text: /Matches logged:\s+0/
  end

  test 'index page loads successfully for authenticated user with matches' do
    oauth_account = create(:oauth_account)
    create(:match, oauth_account: oauth_account, season: 1)
    create(:match, oauth_account: oauth_account, season: 2)
    create(:match, oauth_account: oauth_account, season: 3)

    sign_in_as(oauth_account)
    get "/seasons/#{oauth_account.to_param}"

    assert_response :ok
    assert_select 'div', text: /Matches logged:\s+3/
    assert_select 'div', text: /Active in seasons:\s+1, 2, 3/
  end

  test "won't let you view all season data for another user's account" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)

    sign_in_as(oauth_account1)
    get "/seasons/#{oauth_account2.to_param}"

    assert_response :not_found
  end
end
