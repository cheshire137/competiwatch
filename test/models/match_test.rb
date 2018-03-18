require 'test_helper'

class MatchTest < ActiveSupport::TestCase
  fixtures :heroes, :seasons

  test 'thrower_leaver_percent looks only in specified season' do
    match1 = create(:match, result: :win, season: 1)
    match2 = create(:match, ally_thrower: true, result: :loss, season: 1)
    match3 = create(:match, ally_leaver: true, result: :draw, season: 2)

    assert_equal 50, Match.thrower_leaver_percent(season: 1)
  end

  test 'thrower_leaver_percent returns nil when no matches' do
    assert_nil Match.thrower_leaver_percent
  end

  test 'thrower_leaver_percent returns percentage of matches with a result that had a thrower or leaver' do
    match1 = create(:match, result: :win)
    match2 = create(:match, ally_thrower: true, result: :loss)
    match3 = create(:match, ally_leaver: true, result: :draw)
    match4 = create(:match, enemy_thrower: true, result: :win)
    match5 = create(:match, enemy_leaver: true, result: :win)

    assert_equal 80, Match.thrower_leaver_percent
  end

  test 'with_thrower_or_leaver returns matches that had a thrower or leaver' do
    match1 = create(:match)
    match2 = create(:match, ally_thrower: true)
    match3 = create(:match, ally_leaver: true)
    match4 = create(:match, enemy_thrower: true)
    match5 = create(:match, enemy_leaver: true)

    assert_equal [match2, match3, match4, match5], Match.with_thrower_or_leaver
  end

  test 'next_match returns the match following this one in the season' do
    account = create(:account)
    match1 = create(:match, account: account, season: 1)
    match2 = create(:match, account: account, season: 1, prior_match: match1)

    assert_equal match2, match1.next_match
  end

  test 'updates prior_match on destroy' do
    account = create(:account)
    match1 = create(:match, account: account, season: 1)
    match2 = create(:match, account: account, season: 1, prior_match: match1)
    match3 = create(:match, account: account, season: 1, prior_match: match2)

    match2.destroy!

    assert_equal match1, match3.reload.prior_match
  end

  test 'requires hero_ids to include only valid hero IDs' do
    match = build(:match, hero_ids: [heroes(:ana).id, -1, heroes(:mercy).id])

    refute_predicate match, :valid?
    assert_includes match.errors.messages[:hero_ids], 'contains invalid values: -1'
  end

  test 'prefill_group_members sets group members list from group_member_ids' do
    user = create(:user)
    account = create(:account, user: user)
    friend1 = create(:friend, user: user, name: 'Sally')
    friend2 = create(:friend, user: user, name: 'Jim')
    match1 = create(:match, account: account, group_member_ids: [friend1.id])
    match2 = create(:match, account: account, group_member_ids: [friend1.id, friend2.id])

    Match.prefill_group_members([match1, match2], user: user)

    friend1.destroy
    friend2.destroy

    assert_equal %w[Sally], match1.group_members.map(&:name)
    assert_equal %w[Jim Sally], match2.group_members.map(&:name).sort
  end

  test 'top_accounts returns a hash of accounts with the most matches' do
    account1 = create(:account)
    account2 = create(:account)
    account3 = create(:account)
    2.times { create(:match, account: account1) }
    create(:match, account: account2)
    3.times { create(:match, account: account3) }

    expected = { account3 => 3, account1 => 2 }
    assert_equal expected, Match.top_accounts(limit: 2)
  end

  test 'limits number of matches per season per account' do
    Match.stub_const(:MAX_PER_SEASON, 2) do
      account1 = create(:account)
      season = 1
      match1 = create(:match, account: account1, season: season)
      match2 = create(:match, account: account1, season: season)
      match3 = build(:match, account: account1, season: season)

      refute_predicate match3, :valid?
      assert_includes match3.errors.messages[:base],
        "#{account1} has reached the maximum allowed number of matches in season #{season}."

      account2 = create(:account)
      match4 = build(:match, account: account2, season: season)

      assert_predicate match4, :valid?
    end
  end

  test 'publicly_shared scope includes only matches from shared seasons' do
    account = create(:account)
    create(:season_share, account: account, season: 2)
    unshared_match1 = create(:match, season: 1, account: account)
    shared_match1 = create(:match, season: 2, account: account)
    shared_match2 = create(:match, season: 2, account: account)
    unshared_match2 = create(:match, season: 2) # different account
    unshared_match3 = create(:match, season: 3, account: account)

    result = Match.publicly_shared

    assert_includes result, shared_match1
    assert_includes result, shared_match2
    refute_includes result, unshared_match1
    refute_includes result, unshared_match2
    refute_includes result, unshared_match3
  end

  test 'clears account career high cache if rank is greater' do
    account = create(:account)
    account.delete_career_high_cache

    create(:match, rank: 1234, account: account) # prime the cache
    assert_equal 1234, Rails.cache.fetch("career-high-#{account}")

    create(:match, rank: 1235, account: account) # new career high
    assert_nil Rails.cache.fetch("career-high-#{account}")
    assert_equal 1235, account.career_high
    assert_equal 1235, Rails.cache.fetch("career-high-#{account}")
  end

  test 'requires season' do
    match = Match.new

    refute_predicate match, :valid?
    assert_includes match.errors.messages[:season], "can't be blank"
  end

  test 'updates result when rank changes' do
    account = create(:account)
    match1 = create(:match, account: account, rank: 2500)
    match2 = create(:match, account: account, rank: 2525, prior_match: match1)

    assert_equal :win, match2.result

    match2.rank = 2475
    assert match2.save

    assert_equal :loss, match2.reload.result
  end

  test 'creates new friends from given name list' do
    match = create(:match)
    names = %w[Jamie Seed]

    assert_difference 'Friend.count', 2 do
      match.set_friends_from_names names
      match.save!
    end

    assert_equal names, match.reload.group_member_names
  end

  test 'removes match friends not in given name list' do
    user = create(:user)
    account = create(:account, user: user)
    friend = create(:friend, user: user, name: 'Rob')
    match = create(:match, account: account, group_member_ids: [friend.id])
    other_match = create(:match, account: account, group_member_ids: [friend.id])
    names = %w[Jamie Seed]

    assert_difference 'Friend.count', 2 do
      match.set_friends_from_names names
      match.save!
    end

    assert_equal names, match.reload.group_member_names
    assert Friend.exists?(friend.id),
      'should not delete friend when friend removed from match but still in other matches'
  end

  test 'adds existing friend to match based on name' do
    user = create(:user)
    account = create(:account, user: user)
    friend = create(:friend, user: user, name: 'Rob')
    match = create(:match, account: account, group_member_ids: [friend.id])
    names = %w[Rob Seed]

    assert_difference 'Friend.count' do
      match.set_friends_from_names names
      match.save!
    end

    assert_equal names, match.reload.group_member_names
  end

  test 'leaves existing friend in match when adding another existing friend' do
    user = create(:user)
    account = create(:account, user: user)
    friend1 = create(:friend, user: user, name: 'Rob')
    friend2 = create(:friend, user: user, name: 'Seed')
    match = create(:match, account: account, group_member_ids: [friend1.id])
    names = %w[Rob Seed]

    assert_no_difference 'Friend.count' do
      match.set_friends_from_names names
      match.save!
    end

    assert_equal names, match.reload.group_member_names
  end

  test 'requires friend user to match account user' do
    friend = create(:friend)
    match_user = create(:user)
    match_account = create(:account, user: match_user)
    match = build(:match, account: match_account, group_member_ids: [friend.id])

    refute_predicate match, :valid?
    assert_includes match.errors.messages[:group_member_ids],
      "has a group member who is not #{match_user}'s friend"
  end

  test 'disallows more than 5 others in your match group' do
    user = create(:user)
    friends = []
    6.times { |i| friends << create(:friend, name: "Friend#{i}", user: user) }
    account = create(:account, user: user)
    match = build(:match, account: account, group_member_ids: friends.map(&:id))

    refute_predicate match, :valid?
    assert_includes match.errors.messages[:base],
      'Match already has a full group: you, Friend0, Friend1, Friend2, Friend3, Friend4'
  end

  test 'deletes friends when last match has them removed' do
    user = create(:user)
    account = create(:account, user: user)
    friend1 = create(:friend, user: user)
    friend2 = create(:friend, user: user)
    match = create(:match, account: account, group_member_ids: [friend1.id, friend2.id])

    assert_difference 'Friend.count', -2 do
      match.group_member_ids = []
      match.save!
    end

    refute Friend.exists?(friend1.id)
    refute Friend.exists?(friend2.id)
  end

  test 'deletes friends when last match including them is destroyed' do
    user = create(:user)
    account = create(:account, user: user)
    friend1 = create(:friend, user: user)
    friend2 = create(:friend, user: user)
    match = create(:match, account: account, group_member_ids: [friend1.id, friend2.id])

    assert_difference 'Friend.count', -2 do
      match.destroy!
    end

    refute Friend.exists?(friend1.id)
    refute Friend.exists?(friend2.id)
  end

  test 'requires valid season' do
    match = Match.new(season: 0)

    refute_predicate match, :valid?
    assert_includes match.errors.messages[:season], 'must be greater than or equal to 1'
  end

  test 'requires rank if not a placement match' do
    match = Match.new(placement: false)

    refute_predicate match, :valid?
    assert_includes match.errors.messages[:rank], 'is required if not a placement match'
  end

  test 'sets result at validation time based on rank and prior match rank' do
    prior_match = create(:match, rank: 1234)
    match = Match.new(rank: 1254, prior_match: prior_match)

    match.valid?

    assert_equal :win, match.result
  end

  test 'requires season to be the same as prior match season' do
    prior_match = create(:match)
    match = Match.new(season: prior_match.season + 1, prior_match: prior_match)

    refute_predicate match, :valid?
    assert_includes match.errors.messages[:season], 'must be the same as season from prior match'
  end

  test 'requires rank <= max rank' do
    match = Match.new(rank: Match::MAX_RANK + 1)

    refute_predicate match, :valid?
    assert_includes match.errors.messages[:rank], "must be less than or equal to #{Match::MAX_RANK}"
  end

  test 'requires rank >= 0' do
    match = Match.new(rank: -1)

    refute_predicate match, :valid?
    assert_includes match.errors.messages[:rank], 'must be greater than or equal to 0'
  end
end
