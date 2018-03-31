require 'test_helper'

class CommunityControllerTest < ActionDispatch::IntegrationTest
  fixtures :heroes, :seasons

  test 'anonymous user cannot view community index' do
    get '/community'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'authenticated user can view community index' do
    user = create(:user)
    account = create(:account, user: user)
    friend = create(:friend, user: user)
    good_match = create(:match, result: :win, ally_thrower: false, ally_leaver: false,
                        enemy_thrower: false, enemy_leaver: false)
    match_with_thrower = create(:match, result: :loss, ally_thrower: true)
    match_with_hero = create(:match, result: :win, heroes: [heroes(:ana)])
    match_with_group = create(:match, result: :win, group_members: [friend],
                              account: account)

    sign_in_as(account)
    get '/community'

    assert_response :ok
  end
end
