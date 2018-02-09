require 'test_helper'

class LoginControllerTest < ActionDispatch::IntegrationTest
  test 'loads successfully' do
    get '/'

    assert_response :ok
  end
end
