require 'test_helper'

class OAuthAccountsControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

  test 'anonymous user cannot update profile' do
    oauth_account = create(:oauth_account, platform: 'xbl', region: 'cn')

    put "/profile/#{oauth_account.to_param}", params: {
      oauth_account: { platform: 'psn', region: 'eu' }
    }

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
    assert_equal 'xbl', oauth_account.reload.platform
    assert_equal 'cn', oauth_account.region
  end

  test "cannot update another user's profile" do
    oauth_account1 = create(:oauth_account, platform: 'xbl', region: 'cn')
    oauth_account2 = create(:oauth_account)

    sign_in_as(oauth_account2)
    put "/profile/#{oauth_account1.to_param}", params: {
      oauth_account: { platform: 'psn', region: 'eu' }
    }

    assert_response :not_found
    assert_equal 'xbl', oauth_account1.reload.platform
    assert_equal 'cn', oauth_account1.region
  end

  test 'can update your own profile' do
    oauth_account = create(:oauth_account, platform: 'xbl', region: 'cn')

    sign_in_as(oauth_account)
    put "/profile/#{oauth_account.to_param}", params: {
      oauth_account: { platform: 'psn', region: 'eu' }
    }

    assert_redirected_to profile_path(oauth_account)
    assert_equal 'psn', oauth_account.reload.platform
    assert_equal 'eu', oauth_account.region
  end

  test 'can view your own profile' do
    oauth_account = create(:oauth_account)

    sign_in_as(oauth_account)
    get "/profile/#{oauth_account.to_param}"

    assert_response :ok
  end

  test 'anonymous user cannot view a profile' do
    oauth_account = create(:oauth_account)

    get "/profile/#{oauth_account.to_param}"

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test "cannot view another user's profile" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)

    sign_in_as(oauth_account2)
    get "/profile/#{oauth_account1.to_param}"

    assert_response :not_found
  end

  test 'anonymous user cannot set default account' do
    put '/accounts/set-default'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'authenticated user with multiple accounts can change their default account' do
    user = create(:user)
    oauth_account1 = create(:oauth_account, user: user)
    oauth_account2 = create(:oauth_account, user: user)

    sign_in_as(oauth_account1)
    put '/accounts/set-default', params: { battletag: oauth_account2.to_param }

    assert_equal oauth_account2, user.reload.default_oauth_account
    assert_redirected_to accounts_path
    assert_nil flash[:error]
    assert_equal "Your default account is now #{oauth_account2}.", flash[:notice]
  end

  test 'cannot set your default account to an account not your own' do
    user = create(:user)
    oauth_account1 = create(:oauth_account, user: user)
    oauth_account2 = create(:oauth_account)
    user.default_oauth_account = oauth_account1
    user.save!

    sign_in_as(oauth_account1)
    put '/accounts/set-default', params: { battletag: oauth_account2.to_param }

    assert_response :not_found
    assert_equal oauth_account1, user.reload.default_oauth_account
  end

  test 'index loads for authenticated user' do
    user = create(:user)
    oauth_account1 = create(:oauth_account, user: user)
    oauth_account2 = create(:oauth_account, user: user)

    sign_in_as(oauth_account1)
    get '/accounts'

    assert_response :ok
    assert_select "option[value='#{oauth_account1.to_param}']", text: oauth_account1.battletag
    assert_select "option[value='#{oauth_account2.to_param}']", text: oauth_account2.battletag
  end

  test 'can unlink an account when you have multiple' do
    user = create(:user)
    oauth_account1 = create(:oauth_account, user: user)
    create(:match, oauth_account: oauth_account1)
    oauth_account2 = create(:oauth_account, user: user)

    assert_no_difference ['OAuthAccount.count', 'Match.count'] do
      sign_in_as(oauth_account1)
      delete "/accounts/#{oauth_account1.to_param}"
    end

    assert_redirected_to accounts_path
    assert_equal oauth_account2, user.reload.default_oauth_account
  end
end
