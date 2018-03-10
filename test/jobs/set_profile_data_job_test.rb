require 'test_helper'

class SetProfileDataJobTest < ActiveJob::TestCase
  test 'sets avatar_url, level_url, level, rank on the account' do
    account = create(:account, avatar_url: nil, battletag: 'cheshire137#1695',
                           rank: nil, level: nil, level_url: nil, star_url: nil)

    VCR.use_cassette('ow_api_profile_with_stars') do
      SetProfileDataJob.perform_now(account.id)
    end

    assert_equal 'https://d1u1mce87gyfbn.cloudfront.net/game/unlocks/0x025000000000159D.png',
      account.reload.avatar_url
    assert_equal 'https://d1u1mce87gyfbn.cloudfront.net/game/playerlevelrewards/' \
                 '0x0250000000000988_Border.png', account.level_url
    assert_equal 'https://d1u1mce87gyfbn.cloudfront.net/game/playerlevelrewards/' \
                 '0x0250000000000988_Rank.png', account.star_url
    assert_equal 3508, account.rank
    assert_equal 1090, account.level
  end
end
