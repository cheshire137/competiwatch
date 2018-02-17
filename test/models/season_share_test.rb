require 'test_helper'

class SeasonShareTest < ActiveSupport::TestCase
  test 'requires OAuth account' do
    season_share = SeasonShare.new

    refute_predicate season_share, :valid?
    assert_includes season_share.errors.messages[:oauth_account], 'must exist'
  end

  test 'requires season' do
    season_share = SeasonShare.new

    refute_predicate season_share, :valid?
    assert_includes season_share.errors.messages[:season], "can't be blank"
  end

  test 'requires unique season + OAuth account' do
    season_share1 = create(:season_share)
    season_share2 = SeasonShare.new(season: season_share1.season,
                                    oauth_account: season_share1.oauth_account)

    refute_predicate season_share2, :valid?
    assert_includes season_share2.errors.messages[:season], 'has already been taken'
  end
end
