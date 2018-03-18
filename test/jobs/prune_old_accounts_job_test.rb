require 'test_helper'

class PruneOldAccountsJobTest < ActiveJob::TestCase
  test 'deletes old accounts and their users when they have no matches' do
    user1 = create(:user)
    user2 = create(:user)
    old_account1 = create(:account, updated_at: 4.months.ago, user: user1)
    old_account2 = create(:account, updated_at: 3.months.ago, user: user2)

    assert_difference ['Account.count', 'User.count'], -2 do
      PruneOldAccountsJob.perform_now
    end

    refute Account.exists?(old_account1.id)
    refute Account.exists?(old_account2.id)
    refute User.exists?(user1.id)
    refute User.exists?(user2.id)
  end

  test 'will not delete recently updated account' do
    create(:account, updated_at: 1.month.ago)

    assert_no_difference ['Account.count', 'User.count'] do
      PruneOldAccountsJob.perform_now
    end
  end

  test 'will not delete old account with matches' do
    account = create(:account, updated_at: 5.months.ago)
    create(:match, account: account)

    assert_no_difference ['Account.count', 'User.count'] do
      PruneOldAccountsJob.perform_now
    end
  end

  test 'will not delete old account without matches when its user has another account' do
    user = create(:user)
    create(:account, user: user, updated_at: 1.year.ago)
    create(:account, user: user, updated_at: 7.months.ago)

    assert_no_difference ['Account.count', 'User.count'] do
      PruneOldAccountsJob.perform_now
    end
  end
end
