require 'test_helper'

class MatchTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
  end

  test 'publicly_shared scope includes only matches from shared seasons' do
    oauth_account = create(:oauth_account)
    create(:season_share, oauth_account: oauth_account, season: 2)
    unshared_match1 = create(:match, season: 1, oauth_account: oauth_account)
    shared_match1 = create(:match, season: 2, oauth_account: oauth_account)
    shared_match2 = create(:match, season: 2, oauth_account: oauth_account)
    unshared_match2 = create(:match, season: 2) # different account
    unshared_match3 = create(:match, season: 3, oauth_account: oauth_account)

    result = Match.publicly_shared

    assert_includes result, shared_match1
    assert_includes result, shared_match2
    refute_includes result, unshared_match1
    refute_includes result, unshared_match2
    refute_includes result, unshared_match3
  end

  test 'clears account career high cache if rank is greater' do
    oauth_account = create(:oauth_account)

    create(:match, rank: 1234, oauth_account: oauth_account) # prime the cache
    assert_equal 1234, Rails.cache.fetch("career-high-#{oauth_account}")

    create(:match, rank: 1235, oauth_account: oauth_account) # new career high
    assert_nil Rails.cache.fetch("career-high-#{oauth_account}")
    assert_equal 1235, oauth_account.career_high
    assert_equal 1235, Rails.cache.fetch("career-high-#{oauth_account}")
  end

  test 'requires season' do
    match = Match.new

    refute_predicate match, :valid?
    assert_includes match.errors.messages[:season], "can't be blank"
  end

  test 'updates result when rank changes' do
    oauth_account = create(:oauth_account)
    match1 = create(:match, oauth_account: oauth_account, rank: 2500)
    match2 = create(:match, oauth_account: oauth_account, rank: 2525, prior_match: match1)

    assert_equal :win, match2.result

    match2.rank = 2475
    assert match2.save

    assert_equal :loss, match2.reload.result
  end

  test 'creates new friends from given name list' do
    match = create(:match)
    names = %w[Jamie Seed]

    assert_difference ['MatchFriend.count', 'Friend.count'], 2 do
      match.set_friends_from_names names
    end

    assert_equal names, match.reload.friend_names
  end

  test 'removes match friends not in given name list' do
    user = create(:user)
    oauth_account = create(:oauth_account, user: user)
    match = create(:match, oauth_account: oauth_account)
    other_match = create(:match, oauth_account: oauth_account)
    friend = create(:friend, user: user, name: 'Rob')
    match_friend = create(:match_friend, match: match, friend: friend)
    create(:match_friend, friend: friend, match: other_match)
    names = %w[Jamie Seed]

    assert_difference 'MatchFriend.count' do
      assert_difference 'Friend.count', 2 do
        match.set_friends_from_names names
      end
    end

    assert_equal names, match.reload.friend_names
    refute MatchFriend.exists?(match_friend.id)
    assert Friend.exists?(friend.id),
      'should not delete friend when friend removed from match but still in other matches'
  end

  test 'adds existing friend to match based on name' do
    user = create(:user)
    oauth_account = create(:oauth_account, user: user)
    match = create(:match, oauth_account: oauth_account)
    friend = create(:friend, user: user, name: 'Rob')
    match_friend = create(:match_friend, match: match, friend: friend)
    names = %w[Rob Seed]

    assert_difference 'MatchFriend.count' do
      assert_difference 'Friend.count' do
        match.set_friends_from_names names
      end
    end

    assert_equal names, match.reload.friend_names
  end

  test 'leaves existing friend in match when adding another existing friend' do
    user = create(:user)
    oauth_account = create(:oauth_account, user: user)
    match = create(:match, oauth_account: oauth_account)
    friend1 = create(:friend, user: user, name: 'Rob')
    friend2 = create(:friend, user: user, name: 'Seed')
    match_friend = create(:match_friend, match: match, friend: friend1)
    names = %w[Rob Seed]

    assert_difference 'MatchFriend.count' do
      assert_no_difference 'Friend.count' do
        match.set_friends_from_names names
      end
    end

    assert_equal names, match.reload.friend_names
  end

  test 'deletes friends when deleted' do
    match = create(:match)
    match_friend1 = create(:match_friend, match: match)
    match_friend2 = create(:match_friend, match: match)

    assert_difference 'MatchFriend.count', -2 do
      match.destroy
    end

    refute MatchFriend.exists?(match_friend1.id)
    refute MatchFriend.exists?(match_friend2.id)
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
