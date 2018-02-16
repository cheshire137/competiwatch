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
end
