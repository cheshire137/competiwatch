require 'test_helper'

class SeasonShareTest < ActiveSupport::TestCase
  fixtures :seasons

  test 'with_matches returns season shares for accounts that have matches in given season' do
    account1 = create(:account)
    create(:match, season: 1, account: account1)
    share1 = create(:season_share, account: account1, season: 1)

    account2 = create(:account)
    create(:match, season: 2, account: account2)
    share2 = create(:season_share, account: account2, season: 2)

    account3 = create(:account)
    create(:match, season: 1, account: account3)
    share3 = create(:season_share, account: account3, season: 1)

    assert_equal [share1, share3], SeasonShare.with_matches(1).order(:id)
  end

  test 'requires account' do
    season_share = SeasonShare.new

    refute_predicate season_share, :valid?
    assert_includes season_share.errors.messages[:account], 'must exist'
  end

  test 'requires season' do
    season_share = SeasonShare.new

    refute_predicate season_share, :valid?
    assert_includes season_share.errors.messages[:season], "can't be blank"
  end

  test 'requires unique season + account' do
    season_share1 = create(:season_share)
    season_share2 = SeasonShare.new(season: season_share1.season,
                                    account: season_share1.account)

    refute_predicate season_share2, :valid?
    assert_includes season_share2.errors.messages[:season], 'has already been taken'
  end
end
