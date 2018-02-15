require 'test_helper'

class UserTest < ActiveSupport::TestCase
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

    refute MatchFriend.exists?(friend1.id)
    refute MatchFriend.exists?(friend2.id)
  end

  test 'deletes OAuth accounts when deleted' do
    user = create(:user)
    oauth_account1 = create(:oauth_account, user: user)
    oauth_account2 = create(:oauth_account, user: user)

    assert_difference 'OauthAccount.count', -2 do
      user.destroy
    end

    refute OauthAccount.exists?(oauth_account1.id)
    refute OauthAccount.exists?(oauth_account2.id)
  end

  test "friend_names returns all user's friends when season has no matches" do
    user = create(:user)
    friend1 = create(:friend, user: user, name: 'Tamara')
    friend2 = create(:friend, user: user, name: 'Marcus')
    friend3 = create(:friend, user: user, name: 'Phillipe')

    assert_equal %w[Marcus Phillipe Tamara], user.friend_names(3)
  end

  test 'friend_names returns unique, sorted list of names from friends in matches that season' do
    user = create(:user)
    friend1 = create(:friend, user: user, name: 'Gilly')
    friend2 = create(:friend, user: user, name: 'Alice')
    friend3 = create(:friend, user: user, name: 'Zed')
    oauth_account1 = create(:oauth_account, user: user)
    oauth_account2 = create(:oauth_account, user: user)
    season = 4
    match1 = create(:match, oauth_account: oauth_account1, season: season)
    create(:match_friend, match: match1, friend: friend1)
    match2 = create(:match, oauth_account: oauth_account2, season: season)
    create(:match_friend, match: match2, friend: friend2)
    match3 = create(:match, oauth_account: oauth_account2, season: season + 1)
    create(:match_friend, match: match3, friend: friend3)
    match4 = create(:match, oauth_account: oauth_account2, season: season)
    create(:match_friend, match: match4, friend: friend2)

    result = user.friend_names(season)

    assert_includes result, friend1.name
    assert_includes result, friend2.name
    refute_includes result, friend3.name, 'should not include friend from a different season'
    assert_equal 2, result.size, 'should not return duplicate names'
  end
end
