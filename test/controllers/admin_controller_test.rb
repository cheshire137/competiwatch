require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  test '404s for non-admin' do
    user = create(:user)
    oauth_account = create(:oauth_account, user: user)

    sign_in_as(oauth_account)
    get '/admin'

    assert_response :not_found
  end

  test '404s for anonymous user' do
    get '/admin'

    assert_response :not_found
  end

  test 'loads successfully for admin' do
    user = create(:user, admin: true)
    oauth_account = create(:oauth_account, user: user)

    sign_in_as(oauth_account)
    get '/admin'

    assert_response :ok
  end
end
