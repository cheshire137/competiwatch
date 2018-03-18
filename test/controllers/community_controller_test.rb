require 'test_helper'

class CommunityControllerTest < ActionDispatch::IntegrationTest
  test 'anonymous user can view community index' do
    get '/community'

    assert_response :ok
  end

  test 'authenticated user can view community index' do
    account = create(:account)

    sign_in_as(account)
    get '/community'

    assert_response :ok
  end
end
