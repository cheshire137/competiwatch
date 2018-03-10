require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

  test 'can view your settings' do
    account = create(:account)

    sign_in_as(account)
    get '/settings'

    assert_response :ok
  end
end
