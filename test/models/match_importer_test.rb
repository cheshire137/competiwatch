require 'test_helper'

class MatchImporterTest < ActiveSupport::TestCase
  test 'imports placement matches' do
    oauth_account = create(:oauth_account)
    importer = MatchImporter.new(oauth_account: oauth_account, season: 1)
    path = file_fixture('valid-match-import.csv')

    assert_difference 'oauth_account.matches.placements.count', 6 do
      importer.import(path)
    end
  end
end
