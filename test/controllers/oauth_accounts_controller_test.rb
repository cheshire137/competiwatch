require 'test_helper'

class OauthAccountsControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

  test 'index loads for authenticated user' do
    user = create(:user)
    oauth_account1 = create(:oauth_account, user: user)
    oauth_account2 = create(:oauth_account, user: user)

    sign_in_as(oauth_account1)
    get '/accounts'

    assert_response :ok
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

    assert_redirected_to '/accounts'
    assert_equal oauth_account2, user.reload.default_oauth_account
  end
end
