require 'test_helper'

class MatchExporterTest < ActiveSupport::TestCase
  setup do
    @map1 = create(:map)
    @map2 = create(:map)
    user = create(:user)
    @oauth_account = create(:oauth_account, user: user)
    @friend1 = create(:friend, user: user, name: 'Siege')
    @friend2 = create(:friend, user: user, name: 'Rob')
    @hero1 = create(:hero, name: 'D.Va')
    @hero2 = create(:hero, name: 'Soldier: 76')
    @hero3 = create(:hero, name: 'Zarya')
  end

  test 'generates CSV of season matches' do
    season = 6
    match1 = create(:match, season: season, oauth_account: @oauth_account, rank: 1234,
                    map: nil, prior_match: nil)
    match2 = create(:match, season: season, oauth_account: @oauth_account, rank: 1254,
                    map: @map1, ally_thrower: true, prior_match: match1, time_of_day: :evening)
    match2.heroes << @hero3
    match3 = create(:match, season: season, oauth_account: @oauth_account, rank: 1273,
                    map: @map2, enemy_leaver: true, prior_match: match2, time_of_day: :morning,
                    day_of_week: :weekday)
    match3.heroes << @hero1
    match3.heroes << @hero2
    match4 = create(:match, season: season, oauth_account: @oauth_account, rank: 1295,
                    map: @map1, prior_match: match3, comment: 'this is so cool')
    create(:match_friend, match: match4, friend: @friend1)
    create(:match_friend, match: match4, friend: @friend2)

    exporter = MatchExporter.new(oauth_account: @oauth_account, season: season)
    csv = exporter.export

    assert_predicate csv, :present?, 'should have returned a CSV string'
    lines = csv.split("\n")
    assert_equal 5, lines.size, 'should have a header line and 4 matches'
    assert_equal 'Rank,Map,Comment,Day,Time,Heroes,Ally Leaver,Ally Thrower,Enemy Leaver' +
                 ',Enemy Thrower,Group', lines[0]
    assert_equal %q(1234,,,,,"",,,,,""), lines[1]
    assert_equal %Q(1254,#{@map1.name},,,evening,#{@hero3.name},,Y,,,""), lines[2]
    assert_equal %Q(1273,#{@map2.name},,weekday,morning,"#{@hero1.name}, #{@hero2.name}",,,Y,,""), lines[3]
    assert_equal %Q(1295,#{@map1.name},this is so cool,,,"",,,,,"Rob, Siege"), lines[4]
  end
end
