require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'total_by_account_count returns count of users having X accounts' do
    user1 = create(:user)
    create(:account, user: user1)

    user2 = create(:user)
    create(:account, user: user2)
    create(:account, user: user2)

    user3 = create(:user)
    create(:account, user: user3)
    create(:account, user: user3)

    user4 = create(:user)
    create(:account, user: user4)
    create(:account, user: user4)

    assert_equal 1, User.total_by_account_count(num_accounts: 1)
    assert_equal 3, User.total_by_account_count(num_accounts: 2)
  end

  test 'season_high returns highest rank from given season' do
    user = create(:user)
    account1 = create(:account, user: user)
    account2 = create(:account, user: user)
    create(:match, account: account1, season: 2, rank: 1235)
    create(:match, account: account2, season: 2, rank: 2435)
    create(:match, account: account1, season: 3, rank: 2750)
    create(:match, account: account1, season: 2, rank: 2200)

    assert_equal 2435, user.season_high(2)
  end

  test 'career_high returns highest rank for all accounts' do
    user = create(:user)
    account1 = create(:account, user: user)
    account2 = create(:account, user: user)
    create(:match, account: account1, season: 1, rank: 50)
    create(:match, account: account1, season: 2, rank: 2501)
    create(:match, account: account2, season: 2, rank: 2500)
    create(:match, account: account1, season: 4, rank: 2420)
    create(:match, account: account1, season: 4, rank: nil, placement: true)

    account1.delete_career_high_cache
    account2.delete_career_high_cache

    assert_equal 2501, user.career_high
  end

  test 'active scope includes user with a recent season share' do
    user = create(:user)
    account = create(:account, user: user, updated_at: 1.year.ago)
    create(:season_share, account: account)

    assert_includes User.active, user
  end

  test 'active scope includes user with a recent match' do
    user = create(:user)
    account = create(:account, user: user, updated_at: 1.year.ago)
    create(:match, account: account)

    assert_includes User.active, user
  end

  test 'active_seasons returns list of seasons user had matches across accounts' do
    user = create(:user)
    account1 = create(:account, user: user)
    account2 = create(:account, user: user)
    create(:match, account: account1, season: 1)
    create(:match, account: account1, season: 2)
    create(:match, account: account2, season: 4)

    assert_equal [1, 2, 4], user.active_seasons
  end

  test 'to_param returns parameterized version of battletag' do
    user = User.new(battletag: 'SomeUser#1234')
    assert_equal 'SomeUser-1234', user.to_param
  end

  test 'requires user to own their default OAuth account' do
    user = create(:user)
    user.default_account = create(:account)

    refute_predicate user, :valid?
    assert_includes user.errors.messages[:default_account], 'must be one of your accounts'
  end

  test 'merge_with handles duplicate friends' do
    primary_user = create(:user)
    primary_account = create(:account, user: primary_user)
    friend1 = create(:friend, user: primary_user, name: 'Luis')
    match1 = create(:match, account: primary_account, group_member_ids: [friend1.id])
    secondary_user = create(:user)
    secondary_account = create(:account, user: secondary_user)
    friend2 = create(:friend, user: secondary_user, name: 'Luis')
    match2 = create(:match, account: secondary_account, group_member_ids: [friend2.id])

    assert_difference 'Friend.count', -1 do
      assert secondary_user.merge_with(primary_user), 'should return true on success'
    end

    assert_equal primary_user, friend1.reload.user
    refute Friend.exists?(friend2.id), 'should have deleted friend with same name'
    refute User.exists?(secondary_user.id), 'secondary user should have been deleted'
    assert_equal [friend1], match2.reload.group_members,
      'should have replaced friend in match with existing friend of the same name'
  end

  test 'merge_with moves accounts and friends to given user' do
    primary_user = create(:user, battletag: 'PrimaryUser#123')
    secondary_user = create(:user, battletag: 'SecondaryUser#456')
    friend1 = create(:friend, user: secondary_user)
    friend2 = create(:friend, user: secondary_user)
    account1 = create(:account, user: secondary_user)
    account2 = create(:account, user: secondary_user)

    assert_no_difference ['Account.count', 'Friend.count'] do
      assert_difference 'User.count', -1 do
        assert secondary_user.merge_with(primary_user), 'should return true on success'
        assert_empty secondary_user.accounts.reload
        assert_empty secondary_user.friends.reload
      end
    end

    assert_equal primary_user, friend1.reload.user
    assert_equal primary_user, friend2.reload.user
    assert_equal primary_user, account1.reload.user
    assert_equal primary_user, account2.reload.user
    refute User.exists?(secondary_user.id), 'secondary user should have been deleted'
  end

  test 'requires battletag' do
    user = User.new

    refute_predicate user, :valid?
    assert_includes user.errors.messages[:battletag], "can't be blank"
  end

  test 'requires unique battletag' do
    user1 = create(:user)
    user2 = User.new(battletag: user1.battletag)

    refute_predicate user2, :valid?
    assert_includes user2.errors.messages[:battletag], 'has already been taken'
  end

  test 'deletes friends when deleted' do
    user = create(:user)
    friend1 = create(:friend, user: user)
    friend2 = create(:friend, user: user)

    assert_difference 'Friend.count', -2 do
      user.destroy
    end

    refute Friend.exists?(friend1.id)
    refute Friend.exists?(friend2.id)
  end

  test 'deletes OAuth accounts when deleted' do
    user = create(:user)
    account1 = create(:account, user: user)
    account2 = create(:account, user: user)

    assert_difference 'Account.count', -2 do
      user.destroy
    end

    refute Account.exists?(account1.id)
    refute Account.exists?(account2.id)
  end

  test "friend_names returns empty list when season has no matches" do
    user = create(:user)
    friend1 = create(:friend, user: user, name: 'Tamara')
    friend2 = create(:friend, user: user, name: 'Marcus')
    friend3 = create(:friend, user: user, name: 'Phillipe')

    assert_empty user.friend_names(3)
  end

  test 'friend_names returns unique, sorted list of names from friends in matches that season' do
    user = create(:user)
    friend1 = create(:friend, user: user, name: 'Gilly')
    friend2 = create(:friend, user: user, name: 'Alice')
    friend3 = create(:friend, user: user, name: 'Zed')
    account1 = create(:account, user: user)
    account2 = create(:account, user: user)
    season = 4
    match1 = create(:match, account: account1, season: season, group_member_ids: [friend1.id])
    match2 = create(:match, account: account2, season: season, group_member_ids: [friend2.id])
    match3 = create(:match, account: account2, season: season + 1, group_member_ids: [friend3.id])
    match4 = create(:match, account: account2, season: season, group_member_ids: [friend2.id])

    result = user.friend_names(season)

    assert_includes result, friend1.name
    assert_includes result, friend2.name
    refute_includes result, friend3.name, 'should not include friend from a different season'
    assert_equal 2, result.size, 'should not return duplicate names'
  end
end
