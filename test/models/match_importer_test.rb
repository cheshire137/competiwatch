require 'test_helper'

class MatchImporterTest < ActiveSupport::TestCase
  test 'imports placement matches' do
    oauth_account = create(:oauth_account)
    importer = MatchImporter.new(oauth_account: oauth_account, season: 1)
    path = file_fixture('valid-placement-import.csv')

    assert_difference 'oauth_account.matches.placements.count', 6 do
      importer.import(path)
      assert_empty importer.errors
    end

    matches = oauth_account.matches.placements.ordered_by_time
    assert_equal :win, matches[0].result
    assert_equal :win, matches[1].result
    assert_equal :loss, matches[2].result
    assert_equal :draw, matches[3].result
    assert_equal :loss, matches[4].result
    assert_equal :win, matches[5].result
  end

  test 'imports placement and regular matches from same file' do
    oauth_account = create(:oauth_account)
    importer = MatchImporter.new(oauth_account: oauth_account, season: 1)
    path = file_fixture('valid-placement-and-regular-import.csv')

    assert_difference 'oauth_account.matches.placements.count', 10 do
      assert_difference 'oauth_account.matches.non_placements.count' do
        importer.import(path)
        assert_empty importer.errors
      end
    end

    matches = oauth_account.matches.ordered_by_time
    assert matches[0..9].all? { |match| match.placement? }, 'first 10 matches should be placements'
    assert_equal :win, matches[0].result
    assert_equal matches[0], matches[1].prior_match
    assert_equal :win, matches[1].result
    assert_equal matches[1], matches[2].prior_match
    assert_equal :loss, matches[2].result
    assert_equal matches[2], matches[3].prior_match
    assert_equal :draw, matches[3].result
    assert_equal matches[3], matches[4].prior_match
    assert_equal :loss, matches[4].result
    assert_equal matches[4], matches[5].prior_match
    assert_equal :win, matches[5].result
    assert_equal matches[5], matches[6].prior_match
    assert_equal :win, matches[6].result
    assert_equal matches[6], matches[7].prior_match
    assert_equal :loss, matches[7].result
    assert_equal matches[7], matches[8].prior_match
    assert_equal :win, matches[8].result
    assert_equal matches[8], matches[9].prior_match

    final_placement_match = matches[9]
    refute_nil final_placement_match, 'should have logged a final placement match'
    assert_equal :loss, final_placement_match.result
    assert_equal 3115, final_placement_match.rank

    regular_match = matches[10]
    refute_nil regular_match, 'should have created a regular match'
    assert_equal matches[9], matches[10].prior_match
    assert_equal :win, regular_match.result
    assert_equal 3135, regular_match.rank
    assert_equal 'good teamwork', regular_match.comment
  end
end
