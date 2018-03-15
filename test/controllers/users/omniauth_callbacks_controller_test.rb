require 'test_helper'

class Users::OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'creates an account and user when account does not exist' do
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
