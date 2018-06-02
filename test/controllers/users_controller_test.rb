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

  test 'anonymous user cannot delete their data' do
    delete '/user'

    assert_redirected_to '/'
    get response.header["Location"] # follow redirect
    assert_select '.flash-error', 'You need to sign in or sign up before continuing.'
  end

  test 'user can delete their data' do
    user = create(:user)
    other_user = create(:user)
    account1 = create(:account, user: user)
    account2 = create(:account, user: user)
    other_account = create(:account, user: other_user)
    friend1 = create(:friend, user: user)
    friend2 = create(:friend, user: user)
    other_friend = create(:friend, user: other_user)
    create(:season, number: 3)
    matches = []
    2.times do |i|
      matches << create(:match, account: account1, season: i + 1, group_member_ids: [friend1.id])
    end
    3.times do |i|
      matches << create(:match, account: account2, season: i + 1, group_member_ids: [friend2.id])
    end
    other_match = create(:match, account: other_account)
    share1 = create(:season_share, account: account1, season: 1)
    share2 = create(:season_share, account: account2, season: 2)
    other_share = create(:season_share, account: other_account, season: 1)

    sign_in_as(account1)
    delete '/user'

    assert_redirected_to '/'
    get response.header["Location"] # follow redirect
    assert_select '.flash-success', text: 'Competiwatch account deleted.'
    matches.each do |match|
      refute Match.exists?(match.id), 'match should have been deleted'
    end
    refute User.exists?(user.id), 'current user should have been deleted'
    assert User.exists?(other_user.id), 'other user should not have been deleted'
    refute Account.exists?(account1.id), 'current account should have been deleted'
    refute Account.exists?(account2.id), "user's other account should have been deleted"
    assert Account.exists?(other_account.id), 'other account should not have been deleted'
    refute Friend.exists?(friend1.id), "user's friend should have been deleted"
    refute Friend.exists?(friend2.id), "user's friend should have been deleted"
    assert Friend.exists?(other_friend.id), 'other friend should not have been deleted'
    refute SeasonShare.exists?(share1.id), 'season share should have been deleted'
    refute SeasonShare.exists?(share2.id), 'season share should have been deleted'
    assert SeasonShare.exists?(other_share.id), 'other season share should not have been deleted'
  end
end
