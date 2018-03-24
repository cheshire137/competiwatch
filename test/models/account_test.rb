require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  fixtures :seasons, :heroes

  setup do
    clear_enqueued_jobs
  end

  test 'not_recently_updated returns accounts not updated for more than 2 months' do
    old_account1 = create(:account, updated_at: 3.months.ago)
    old_account2 = create(:account, updated_at: 1.year.ago)
    account3 = create(:account, updated_at: 1.month.ago)

    assert_equal [old_account1, old_account2], Account.not_recently_updated
  end

  test 'sole_accounts and without_matches are chainable' do
    user1 = create(:user)
    account1 = create(:account, user: user1)
    create(:match, account: account1)

    user2 = create(:user)
    account2 = create(:account, user: user2)
    account3 = create(:account, user: user2)
    create(:match, account: account3)

    user3 = create(:user)
    account4 = create(:account, user: user3)

    assert_equal [account4], Account.without_matches.sole_accounts
  end

  test 'sole_accounts returns accounts that are the sole account for their user' do
    user1 = create(:user)
    account1 = create(:account, user: user1)

    user2 = create(:user)
    account2 = create(:account, user: user2)
    account3 = create(:account, user: user2)

    user3 = create(:user)
    account4 = create(:account, user: user3)

    assert_equal [account1, account4], Account.sole_accounts.order(:id)
  end

  test 'without_matches returns accounts that have not logged a match' do
    account1 = create(:account)
    create(:match, account: account1)

    account2 = create(:account)

    account3 = create(:account)
    create(:match, account: account3)
    create(:match, account: account3)

    assert_equal [account2], Account.without_matches
  end

  test 'updates profile data when platform changes' do
    account = create(:account, platform: 'pc')
    account.platform = 'psn'

    assert_difference 'enqueued_jobs.size' do
      account.save!
    end

    enqueued_job = enqueued_jobs.first
    refute_nil enqueued_job
    assert_equal SetProfileDataJob, enqueued_job[:job]
    assert_equal [account.id], enqueued_job[:args]
  end

  test 'most_played_heroes returns a hash of the heroes and match counts' do
    account = create(:account)
    other_account = create(:account)
    match1 = create(:match, account: account, heroes: [heroes(:ana), heroes(:mercy)])
    match2 = create(:match, account: account, heroes: [heroes(:ana), heroes(:mercy)])
    match3 = create(:match, account: account, heroes: [heroes(:mccree)])
    other_match = create(:match, account: other_account, heroes: [heroes(:mccree)])

    expected = { heroes(:ana) => 2, heroes(:mercy) => 2, heroes(:mccree) => 1 }
    assert_equal expected, account.most_played_heroes
  end

  test 'out_of_date? returns true for account not updated recently' do
    account = create(:account, updated_at: 1.month.ago)
    assert_predicate account, :out_of_date?
  end

  test 'out_of_date? returns false for account that has been updated recently' do
    account = create(:account, updated_at: 2.days.ago)
    refute_predicate account, :out_of_date?
  end

  test 'requires rank <= max rank' do
    account = Account.new(rank: Match::MAX_RANK + 1)

    refute_predicate account, :valid?
    assert_includes account.errors.messages[:rank],
      "must be less than or equal to #{Match::MAX_RANK}"
  end

  test 'requires rank >= 0' do
    account = Account.new(rank: -1)

    refute_predicate account, :valid?
    assert_includes account.errors.messages[:rank], 'must be greater than or equal to 0'
  end

  test 'requires level >= 1' do
    account = Account.new(level: 0)

    refute_predicate account, :valid?
    assert_includes account.errors.messages[:level], 'must be greater than or equal to 1'
  end

  test 'name returns battletag without the number' do
    account = Account.new(battletag: 'SomeUser#1234')
    assert_equal 'SomeUser', account.name
  end

  test 'requires valid URL for avatar_url' do
    account = Account.new(avatar_url: 'https:/some-site.com')

    refute_predicate account, :valid?
    assert_includes account.errors.messages[:avatar_url], 'is invalid'
  end

  test 'requires valid URL for star_url' do
    account = Account.new(star_url: 'https:/some-site.com')

    refute_predicate account, :valid?
    assert_includes account.errors.messages[:star_url], 'is invalid'
  end

  test 'requires valid URL for level_url' do
    account = Account.new(level_url: 'https:/some-site.com')

    refute_predicate account, :valid?
    assert_includes account.errors.messages[:level_url], 'is invalid'
  end

  test 'to_param returns nil when no battletag' do
    assert_nil Account.new.to_param
  end

  test 'to_param returns parameterized version of battletag' do
    account = Account.new(battletag: 'SomeUser#1234')
    assert_equal 'SomeUser-1234', account.to_param
  end

  test 'career_high is nil for new account' do
    assert_nil Account.new.career_high
  end

  test 'career_high is nil for account with no matches' do
    account = create(:account)
    account.delete_career_high_cache

    assert_nil account.career_high
  end

  test 'career_high returns highest rank for account' do
    account = create(:account)
    create(:match, account: account, season: 1, rank: 50)
    create(:match, account: account, season: 2, rank: 2501)
    create(:match, account: account, season: 4, rank: 2420)
    account.delete_career_high_cache

    assert_equal 2501, account.career_high
    assert_equal 2501, Rails.cache.fetch("career-high-#{account}")
  end

  test 'active_seasons returns list of seasons account had matches' do
    account = create(:account)
    create(:match, account: account, season: 2)
    create(:match, account: account, season: 1)
    create(:match, account: account, season: 3)

    assert_equal [1, 2, 3], account.active_seasons
  end

  test 'season_high returns highest rank from given season' do
    account = create(:account)
    create(:match, account: account, season: 2, rank: 1235)
    create(:match, account: account, season: 3, rank: 2750)
    create(:match, account: account, season: 2, rank: 2200)

    assert_equal 2200, account.season_high(2)
  end

  test 'season_is_public? returns true when a season share exists' do
    account = create(:account)
    season = seasons(:two)
    season_share = create(:season_share, account: account, season: season.number)

    assert account.season_is_public?(season.number)
  end

  test 'season_is_public? returns false when no season share exists' do
    account = create(:account)

    refute account.season_is_public?(4)
  end

  test 'season_is_public? returns false when season share exists for a different season' do
    account = create(:account)
    season_share = create(:season_share, account: account, season: 2)

    refute account.season_is_public?(3)
  end

  test 'removes itself as default_account from user if user is unlinked' do
    user = create(:user)
    account1 = create(:account, user: user)
    account2 = create(:account, user: user)
    user.default_account = account1
    user.save!

    account1.user = nil
    account1.save!

    assert_equal account2, user.reload.default_account,
      'user default OAuth account should be updated'
  end

  test "can_be_unlinked? returns true when it is not the user's only account" do
    user = create(:user)
    account1 = create(:account, user: user)
    account2 = create(:account, user: user)

    assert_predicate account1, :can_be_unlinked?
    assert_predicate account2, :can_be_unlinked?
  end

  test "can_be_unlinked? returns false when it is the user's only account" do
    user = create(:user)
    account = create(:account, user: user)

    refute_predicate account, :can_be_unlinked?
  end

  test "default? returns true when it is the user's default OAuth account" do
    account = create(:account)
    account.user.default_account = account

    assert_predicate account, :default?
  end

  test "default? returns false when it is not the user's default OAuth account" do
    account = create(:account)

    refute_predicate account, :default?
  end

  test 'requires battletag' do
    account = Account.new

    refute_predicate account, :valid?
    assert_includes account.errors.messages[:battletag], "can't be blank"
  end

  test 'raises exception when trying to delete account with matches' do
    account = create(:account)
    match1 = create(:match, account: account)
    match2 = create(:match, account: account)

    assert_no_difference 'Match.count' do
      assert_raises ActiveRecord::DeleteRestrictionError do
        account.reload.destroy
      end
    end

    assert Match.exists?(match1.id)
    assert Match.exists?(match2.id)
  end

  test 'deletes season shares when deleted' do
    account = create(:account)
    share1 = create(:season_share, account: account, season: seasons(:one).number)
    share2 = create(:season_share, account: account, season: seasons(:two).number)

    assert_difference 'SeasonShare.count', -2 do
      account.reload.destroy
    end

    refute SeasonShare.exists?(share1.id)
    refute SeasonShare.exists?(share2.id)
  end

  test 'requires provider' do
    account = Account.new

    refute_predicate account, :valid?
    assert_includes account.errors.messages[:provider], "can't be blank"
  end

  test 'requires unique battletag + uid + provider' do
    account1 = create(:account)
    account2 = Account.new(uid: account1.uid, battletag: account1.battletag,
                                      provider: account1.provider)

    refute_predicate account2, :valid?
    assert_includes account2.errors.messages[:uid], 'has already been taken'
  end
end
