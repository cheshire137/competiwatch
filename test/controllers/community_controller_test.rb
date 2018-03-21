require 'test_helper'

class CommunityControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

  test 'anonymous user cannot view community index' do
    get '/community'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'authenticated user can view community index' do
    account = create(:account)
    good_match = create(:match, result: :win, ally_thrower: false, ally_leaver: false,
                        enemy_thrower: false, enemy_leaver: false)
    match_with_thrower = create(:match, result: :loss, ally_thrower: true)

    sign_in_as(account)
    get '/community'

    assert_response :ok
  end
end
