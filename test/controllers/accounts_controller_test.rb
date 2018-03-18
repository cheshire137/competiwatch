require 'test_helper'

class AccountsControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons, :heroes

  test 'anonymous user cannot update profile' do
    account = create(:account, platform: 'xbl', region: 'cn')

    put "/profile/#{account.to_param}", params: {
      account: { platform: 'psn', region: 'eu' }
    }

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
    assert_equal 'xbl', account.reload.platform
    assert_equal 'cn', account.region
  end

  test "cannot update another user's profile" do
    account1 = create(:account, platform: 'xbl', region: 'cn')
    account2 = create(:account)

    sign_in_as(account2)
    put "/profile/#{account1.to_param}", params: {
      account: { platform: 'psn', region: 'eu' }
    }

    assert_response :not_found
    assert_equal 'xbl', account1.reload.platform
    assert_equal 'cn', account1.region
  end

  test 'can update your own profile' do
    account = create(:account, platform: 'xbl', region: 'cn')

    sign_in_as(account)
    put "/profile/#{account.to_param}", params: {
      account: { platform: 'psn', region: 'eu' }
    }

    assert_redirected_to accounts_path
    assert_equal 'psn', account.reload.platform
    assert_equal 'eu', account.region
  end

  test 'can view your own profile' do
    account = create(:account, battletag: 'MarchHare#11348')
    create(:match, season: 1, account: account)

    VCR.use_cassette('ow_api_profile') do
      sign_in_as(account)
      get "/profile/#{account.to_param}"
    end

    assert_response :ok
    assert_select 'a', text: /Season 1\s+1\s+match/
  end

  test 'anonymous user can view a profile' do
    account = create(:account, battletag: 'MarchHare#11348')
    create(:season_share, account: account, season: 1)
    create(:match, season: 1, account: account)
    create(:match, season: 2, account: account)

    VCR.use_cassette('ow_api_profile') do
      get "/profile/#{account.to_param}"
    end

    assert_response :ok
    assert_select 'a', text: /Season 1\s+1\s+match/
    refute_includes response.body, 'Season 2'
  end

  test "can view another user's profile" do
    account1 = create(:account, battletag: 'MarchHare#11348')
    account2 = create(:account)
    create(:season_share, account: account1, season: 1)
    create(:match, season: 1, account: account1)
    create(:match, season: 2, account: account1)

    VCR.use_cassette('ow_api_profile') do
      sign_in_as(account2)
      get "/profile/#{account1.to_param}"
    end

    assert_response :ok
    assert_select 'a', text: /Season 1\s+1\s+match/
    refute_includes response.body, 'Season 2'
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
