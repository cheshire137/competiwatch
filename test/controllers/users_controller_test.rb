require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

  test 'cannot view settings as anonymous user' do
    get '/settings'

    assert_response :redirect
  end

  test 'user can view their settings' do
    account = create(:account)

    sign_in_as(account)
    get '/settings'

    assert_response :ok
  end

  test 'user can view account deletion confirmation page' do
    account = create(:account)

    sign_in_as(account)
    get '/user/delete-account'

    assert_response :ok
  end

  test 'cannot view account deletion confirmation page as anonymous user' do
    get '/user/delete-account'

    assert_response :redirect
  end
end
