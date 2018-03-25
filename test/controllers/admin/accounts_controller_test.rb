require 'test_helper'

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  fixtures :seasons

  setup do
    clear_enqueued_jobs
  end

  test 'non-admin cannot view list of accounts' do
    account = create(:account)

    sign_in_as(account)
    get '/admin/accounts'

    assert_response :not_found
  end

  test 'non-admin cannot view account' do
    account1 = create(:account)
    account2 = create(:account)

    sign_in_as(account1)
    get "/admin/account/#{account2.id}"

    assert_response :not_found
  end

  test 'anonymous user cannot view account' do
    account = create(:account)

    get "/admin/account/#{account.id}"

    assert_response :not_found
  end

  test 'admin can view account' do
    admin_account = create(:account, admin: true)
    account = create(:account)

    sign_in_as(admin_account)
    get "/admin/account/#{account.id}"

    assert_response :ok
  end

  test 'admin can view list of accounts' do
    admin_account = create(:account, admin: true)
    userless_account = create(:account, user: nil)
    deletable_account = create(:account, updated_at: 1.year.ago)

    sign_in_as(admin_account)
    get '/admin/accounts'

    assert_response :ok
    assert_select '.test-userless-accounts li', text: userless_account.battletag
    assert_select '.test-deletable-accounts li', text: deletable_account.battletag
    assert_select "form[action='#{admin_prune_accounts_path}'] input[name='_method'][value='delete']"
  end

  test 'non-admin cannot prune old accounts' do
    account = create(:account)

    assert_difference 'enqueued_jobs.size' do
      sign_in_as(account)
      delete '/admin/accounts/prune'

      assert_response :not_found
    end

    prune_job = enqueued_jobs.detect { |enqueued_job| enqueued_job[:job] == PruneOldAccountsJob }
    assert_nil prune_job

    profile_job = enqueued_jobs.detect { |enqueued_job| enqueued_job[:job] == SetProfileDataJob }
    refute_nil profile_job
    assert_equal [account.id], profile_job[:args]
  end

  test 'anonymous user cannot prune old accounts' do
    assert_no_difference 'enqueued_jobs.size' do
      delete '/admin/accounts/prune'

      assert_response :not_found
    end
  end

  test 'admin can prune old accounts' do
    admin_account = create(:account, admin: true)

    assert_difference 'enqueued_jobs.size', 2 do
      sign_in_as(admin_account)
      delete '/admin/accounts/prune'

      assert_redirected_to admin_accounts_path
      assert_equal 'Deleting old sole accounts without matches...', flash[:notice]
    end

    prune_job = enqueued_jobs.detect { |enqueued_job| enqueued_job[:job] == PruneOldAccountsJob }
    refute_nil prune_job
    assert_empty prune_job[:args]
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
    assert_redirected_to admin_account_path(account.id)
    assert_equal user, account.reload.user
  end

  test 'anonymous users cannot kick off profile update job' do
    account = create(:account)

    assert_no_difference 'enqueued_jobs.size' do
      put '/admin/account/update-profile', params: { id: account.id }

      assert_response :not_found
    end
  end

  test 'non-admin cannot kick off profile update job' do
    account = create(:account)

    assert_difference 'enqueued_jobs.size' do
      sign_in_as(create(:account))
      put '/admin/account/update-profile', params: { id: account.id }

      assert_response :not_found
    end

    profile_job = enqueued_jobs.detect do |enqueued_job|
      enqueued_job[:job] == SetProfileDataJob && [account.id] == enqueued_job[:args]
    end
    assert_nil profile_job
  end

  test 'admin can kick off profile update job' do
    admin_account = create(:account, admin: true)
    account = create(:account)

    assert_difference 'enqueued_jobs.size', 2 do
      sign_in_as(admin_account)
      put '/admin/account/update-profile', params: { id: account.id }
    end

    assert_equal "Updating #{account}...", flash[:notice]
    assert_redirected_to admin_account_path(account.id)

    profile_job = enqueued_jobs.detect do |enqueued_job|
      enqueued_job[:job] == SetProfileDataJob && [account.id] == enqueued_job[:args]
    end
    refute_nil profile_job
  end
end
