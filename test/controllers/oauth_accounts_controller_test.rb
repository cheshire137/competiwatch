require 'test_helper'

class OauthAccountsControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

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

    assert_no_difference ['OauthAccount.count', 'Match.count'] do
      sign_in_as(oauth_account1)
      delete "/accounts/#{oauth_account1.to_param}"
    end

    assert_redirected_to accounts_path
    assert_equal oauth_account2, user.reload.default_oauth_account
  end
end
