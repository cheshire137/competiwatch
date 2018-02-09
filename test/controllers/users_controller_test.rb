require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test 'can view your settings' do
    oauth_account = create(:oauth_account)

    sign_in_as(oauth_account)
    get '/settings'

    assert_response :ok
  end
end
