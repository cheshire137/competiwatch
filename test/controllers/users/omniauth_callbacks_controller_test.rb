require 'test_helper'

class Users::OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  fixtures :seasons

  test 'existing accounts can sign in when signups are disabled' do
    ENV['ALLOW_SIGNUPS'] = nil
    account = create(:account)
    uid = '123'
    mock_bnet_omniauth(uid: account.uid, battletag: account.battletag)

    assert_no_difference ['Account.count', 'User.count'] do
      post '/users/auth/bnet/callback', params: { battletag: account.battletag }
      assert_redirected_to matches_path(2, account)
      get response.header["Location"] # follow redirect
      assert_select '.flash-error', false
    end
  end

  test 'will not create a new account when signups are not enabled' do
    ENV['ALLOW_SIGNUPS'] = nil
    uid = '123'
    battletag = 'SomeAccount#1234'
    mock_bnet_omniauth(uid: uid, battletag: battletag)

    assert_no_difference ['Account.count', 'User.count'] do
      post '/users/auth/bnet/callback', params: { battletag: battletag }
      assert_redirected_to '/'
      get response.header["Location"] # follow redirect
      assert_select '.flash-error', text: 'New account signups are not allowed at this time.'
    end
  end

  test 'creates an account and user when account does not exist' do
    ENV['ALLOW_SIGNUPS'] = '1'
    uid = '123'
    battletag = 'Somebody#1234'
    mock_bnet_omniauth(uid: uid, battletag: battletag)

    assert_difference ['Account.count', 'User.count'] do
      post '/users/auth/bnet/callback', params: { battletag: battletag }
    end

    new_account = Account.where(battletag: battletag, provider: 'bnet', uid: uid).first
    refute_nil new_account

    new_user = User.where(battletag: battletag).first
    refute_nil new_user
    assert_equal new_user, new_account.user
  end
end
