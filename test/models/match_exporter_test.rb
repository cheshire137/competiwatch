require 'test_helper'

class MatchExporterTest < ActiveSupport::TestCase
  fixtures :heroes

  setup do
    @map1 = create(:map)
    @map2 = create(:map)

    user = create(:user)
    @account = create(:account, user: user)

    @friend1 = create(:friend, user: user, name: 'Siege')
    @friend2 = create(:friend, user: user, name: 'Rob')

    @hero1 = heroes(:dva)
    @hero2 = heroes(:soldier_76)
    @hero3 = heroes(:zarya)

    @season = 6

    @match1 = create(:match, season: @season, account: @account, rank: 1234,
                     map: nil, prior_match: nil)

    @match2 = create(:match, season: @season, account: @account, rank: 1254,
                     map: @map1, ally_thrower: true, prior_match: @match1, time_of_day: :evening)
    @match2.heroes << @hero3

    @match3 = create(:match, season: @season, account: @account, rank: 1273,
                     map: @map2, enemy_leaver: true, prior_match: @match2, time_of_day: :morning,
                     day_of_week: :weekday)
    @match3.heroes << @hero1
    @match3.heroes << @hero2

    @match4 = create(:match, season: @season, account: @account, rank: 1295,
                     map: @map1, prior_match: @match3, comment: 'this is so cool')
    create(:match_friend, match: @match4, friend: @friend1)
    create(:match_friend, match: @match4, friend: @friend2)
  end

  test 'generates CSV of season matches' do
    exporter = MatchExporter.new(account: @account, season: @season)

    csv = exporter.export

    assert_predicate csv, :present?, 'should have returned a CSV string'
    lines = csv.split("\n")
    assert_equal 5, lines.size, 'should have a header line and 4 matches'
    assert_equal 'Rank,Map,Comment,Day,Time,Heroes,Ally Leaver,Ally Thrower,Enemy Leaver' +
                 ',Enemy Thrower,Group,Placement,Result', lines[0]
    assert_equal %q(1234,,,,,"",,,,,"",,), lines[1]
    assert_equal %Q(1254,#{@map1.name},,,evening,#{@hero3.name},,Y,,,"",,win), lines[2]
    assert_equal %Q(1273,#{@map2.name},,weekday,morning,"#{@hero1.name}, #{@hero2.name}",,,Y,,"",,win), lines[3]
    assert_equal %Q(1295,#{@map1.name},this is so cool,,,"",,,,,"Rob, Siege",,win), lines[4]
  end

  test 'generated CSV can be imported' do
    exporter = MatchExporter.new(account: @account, season: @season)
    csv = exporter.export
    path = Rails.root.join('tmp', 'export-test.csv')
    File.open(path, 'w') { |file| file.puts csv }

    importer = MatchImporter.new(account: @account, season: @season)
    assert_no_difference ['Match.count', 'Friend.count', 'MatchFriend.count'] do
      importer.import(path)
      assert_empty importer.errors
    end

    match1 = @account.matches.in_season(@season).find_by_rank(1234)
    refute_nil match1, 'should have recreated match1'
    assert_nil match1.map

    match2 = @account.matches.in_season(@season).find_by_rank(1254)
    refute_nil match2, 'should have recreated match2'
    assert_equal @map1, match2.map
    assert_predicate match2, :ally_thrower?
    assert_equal [@hero3], match2.heroes
    assert_equal :evening, match2.time_of_day

    match3 = @account.matches.in_season(@season).find_by_rank(1273)
    refute_nil match3, 'should have recreated match3'
    assert_equal @map2, match3.map
    assert_equal [@hero1, @hero2], match3.heroes
    assert_equal :morning, match3.time_of_day
    assert_equal :weekday, match3.day_of_week
    assert_predicate match3, :enemy_leaver?

    match4 = @account.matches.in_season(@season).find_by_rank(1295)
    refute_nil match4, 'should have recreated match4'
    assert_equal @map1, match4.map
    assert_equal 'this is so cool', match4.comment
    assert_empty match4.heroes
    assert_equal [@friend2, @friend1].map(&:name), match4.friends.map(&:name)

    File.delete(path)
  end
end
