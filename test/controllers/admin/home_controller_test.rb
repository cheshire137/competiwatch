require 'test_helper'

class Admin::HomeControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons, :heroes

  test '404s for non-admin' do
    user = create(:user)
    account = create(:account, user: user)

    sign_in_as(account)
    get '/admin'

    assert_response :not_found
  end

  test '404s for anonymous user' do
    get '/admin'

    assert_response :not_found
  end

  test 'loads successfully for admin' do
    admin_account = create(:account, admin: true)
    match1 = create(:match, season: 1, heroes: [heroes(:mercy)])
    user = create(:user)
    account = create(:account, user: user)
    friend = create(:friend, user: user)
    match2 = create(:match, result: :win, season: 2, account: account,
                    group_member_ids: [friend.id], heroes: [heroes(:ana)])
    placement_match = create(:match, placement: true, season: 1)
    placement_log_match = create(:match, placement: false, season: 1, map: nil,
                                 prior_match: nil, rank: 3000)

    sign_in_as(admin_account)
    get '/admin'

    assert_response :ok
    assert_select 'button', text: /#{admin_account.name}/
    assert_select '.test-latest-matches span', text: 'Placement log'
    assert_select '.test-latest-matches span', text: 'Placement'
    assert_select '.test-latest-matches span', text: 'Win'
    assert_select '.test-latest-matches span', text: '1 hero'
  end
end
