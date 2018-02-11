require 'test_helper'

class MatchExporterTest < ActiveSupport::TestCase
  setup do
    @map1 = create(:map, name: 'Hanamura')
    @map2 = create(:map, name: 'Junkertown')
    @oauth_account = create(:oauth_account)
    @hero1 = create(:hero, name: 'Genji')
  end

  test 'generates CSV of season matches' do
    season = 6
    match1 = create(:match, season: season, oauth_account: @oauth_account, rank: 1234,
                    map: nil, prior_match: nil)
    match2 = create(:match, season: season, oauth_account: @oauth_account, rank: 1254,
                    map: @map1, ally_thrower: true, prior_match: match1, time_of_day: :evening)
    match3 = create(:match, season: season, oauth_account: @oauth_account, rank: 1273,
                    map: @map2, enemy_leaver: true, prior_match: match2, time_of_day: :morning,
                    day_of_week: :weekday)
    match3.heroes << @hero1
    match4 = create(:match, season: season, oauth_account: @oauth_account, rank: 1295,
                    map: @map1, prior_match: match3, comment: 'this is so cool')

    exporter = MatchExporter.new(oauth_account: @oauth_account, season: season)
    csv = exporter.export

    assert_predicate csv, :present?, 'should have returned a CSV string'
    lines = csv.split("\n")
    assert_equal 5, lines.size, 'should have a header line and 4 matches'
    assert_equal 'Rank,Map,Comment,Day,Time,Heroes,Ally Leaver,Ally Thrower,Enemy Leaver' +
                 ',Enemy Thrower', lines[0]
    assert_equal %q(1234,,,,,"",,,,), lines[1]
    assert_equal %q(1254,Hanamura,,,evening,"",,Y,,), lines[2]
    assert_equal %q(1273,Junkertown,,weekday,morning,Genji,,,Y,), lines[3]
    assert_equal %q(1295,Hanamura,this is so cool,,,"",,,,), lines[4]
  end
end
