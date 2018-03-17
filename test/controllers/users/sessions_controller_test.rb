require 'test_helper'

class Users::SessionsControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

  test 'user is redirected to home on logout' do
    account = create(:account)

    sign_in_as(account)
    delete '/sign_out'

    assert_redirected_to '/'
  end
end
