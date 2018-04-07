require 'test_helper'

class CommunityControllerTest < ActionDispatch::IntegrationTest
  fixtures :heroes, :seasons

  test 'anonymous user cannot view community index' do
    get '/community'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'anonymous user cannot view group size' do
    get '/community/group-size'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'anonymous user cannot view top profile icons' do
    get '/community/top-profile-icons'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'anonymous user cannot view most winning heroes' do
    get '/community/most-winning-heroes'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'authenticated user can view group size' do
    account = create(:account)

    sign_in_as(account)
    get '/community/group-size'

    assert_response :ok
    assert_template 'community/group_size'
  end

  test 'authenticated user can view top profile icons' do
    account = create(:account)

    sign_in_as(account)
    get '/community/top-profile-icons'

    assert_response :ok
    assert_template 'community/top_profile_icons'
  end

  test 'authenticated user can view most winning heroes' do
    account = create(:account)

    sign_in_as(account)
    get '/community/most-winning-heroes'

    assert_response :ok
    assert_template 'community/most_winning_heroes'
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
