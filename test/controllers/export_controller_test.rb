require 'test_helper'

class ExportControllerTest < ActionDispatch::IntegrationTest
  setup do
    @season = seasons(:two)
  end

  test 'index page redirects anonymous user' do
    get '/export'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test "cannot export another user's season" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)

    sign_in_as(oauth_account1)
    post "/season/#{@season}/#{oauth_account2.to_param}/export.csv"

    assert_response :not_found
  end

  test 'can export your own season' do
    oauth_account = create(:oauth_account)

    sign_in_as(oauth_account)
    post "/season/#{@season}/#{oauth_account.to_param}/export.csv"

    assert_response :ok
  end
end
