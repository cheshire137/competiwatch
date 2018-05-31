require 'test_helper'

class AccountsControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons, :heroes

  test 'anonymous user cannot update profile' do
    account = create(:account, platform: 'xbl')

    put "/profile/#{account.to_param}", params: {
      account: { platform: 'psn' }
    }

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
    assert_equal 'xbl', account.reload.platform
  end

  test "cannot update another user's profile" do
    account1 = create(:account, platform: 'xbl')
    account2 = create(:account)

    sign_in_as(account2)
    put "/profile/#{account1.to_param}", params: {
      account: { platform: 'psn' }
    }

    assert_response :not_found
    assert_equal 'xbl', account1.reload.platform
  end

  test 'can update your own profile' do
    account = create(:account, platform: 'xbl')

    sign_in_as(account)
    put "/profile/#{account.to_param}", params: {
      account: { platform: 'psn' }
    }

    assert_redirected_to accounts_path
    assert_equal 'psn', account.reload.platform
  end

  test 'anonymous user cannot set default account' do
    put '/accounts/set-default'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'authenticated user with multiple accounts can change their default account' do
    user = create(:user)
    account1 = create(:account, user: user)
    account2 = create(:account, user: user)

    sign_in_as(account1)
    put '/accounts/set-default', params: { battletag: account2.to_param }

    assert_equal account2, user.reload.default_account
    assert_redirected_to accounts_path
    assert_nil flash[:error]
    assert_equal "Your default account is now #{account2}.", flash[:notice]
  end

  test 'cannot set your default account to an account not your own' do
    user = create(:user)
    account1 = create(:account, user: user)
    account2 = create(:account)
    user.default_account = account1
    user.save!

    sign_in_as(account1)
    put '/accounts/set-default', params: { battletag: account2.to_param }

    assert_response :not_found
    assert_equal account1, user.reload.default_account
  end

  test 'index loads for authenticated user' do
    user = create(:user)
    account1 = create(:account, user: user)
    account2 = create(:account, user: user)

    sign_in_as(account1)
    get '/accounts'

    assert_response :ok
    assert_select "option[value='#{account1.to_param}']", text: account1.battletag
    assert_select "option[value='#{account2.to_param}']", text: account2.battletag
  end

  test 'can unlink an account when you have multiple' do
    user = create(:user)
    account1 = create(:account, user: user)
    create(:match, account: account1)
    account2 = create(:account, user: user)

    assert_no_difference ['Account.count', 'Match.count'] do
      sign_in_as(account1)
      delete "/accounts/#{account1.to_param}"
    end

    assert_redirected_to accounts_path
    assert_equal account2, user.reload.default_account
  end
end
