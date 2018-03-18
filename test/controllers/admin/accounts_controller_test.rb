require 'test_helper'

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

  test 'non-admin cannot view accounts' do
    account = create(:account)

    sign_in_as(account)
    get '/admin/accounts'

    assert_response :not_found
  end

  test 'admin can view accounts' do
    admin_account = create(:account, admin: true)
    userless_account = create(:account, user: nil)

    sign_in_as(admin_account)
    get '/admin/accounts'

    assert_response :ok
    assert_select 'li', text: userless_account.battletag
  end

  test 'non-admin cannot edit accounts' do
    account = create(:account)
    user = create(:user)
    value_before = account.user

    sign_in_as(account)
    post '/admin/account', params: {
      user_id: user.id, account_id: account.id
    }

    assert_response :not_found
    assert_equal value_before, account.reload.user
  end

  test 'admin gets warning if user ID is not specified when editing an account' do
    user = create(:user)
    admin_account = create(:account, admin: true, user: user)

    sign_in_as(admin_account)
    post '/admin/account', params: { account_id: admin_account.id }

    assert_nil flash[:notice]
    assert_equal 'Please specify a user and an account.', flash[:error]
    assert_equal user, admin_account.reload.user
    assert_redirected_to admin_path
  end

  test 'admin can change which user an account is tied to' do
    account = create(:account)
    user = create(:user)
    admin_account = create(:account, admin: true)

    sign_in_as(admin_account)
    post '/admin/account', params: {
      user_id: user.id, account_id: account.id
    }

    assert_equal "Successfully tied account #{account} to user #{user}.", flash[:notice]
    assert_redirected_to admin_path
    assert_equal user, account.reload.user
  end
end
