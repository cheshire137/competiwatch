require 'test_helper'

class SetProfileDataJobTest < ActiveJob::TestCase
  test 'sets avatar_url, level_url, level, rank on the account' do
    account = create(:account, avatar_url: nil, battletag: 'MarchHare#11348',
                     rank: nil, level: nil, level_url: nil)

    VCR.use_cassette('ow_api_profile') do
      SetProfileDataJob.perform_now(account.id)
    end

    assert_equal 'https://d1u1mce87gyfbn.cloudfront.net/game/unlocks/0x02500000000013FE.png',
      account.reload.avatar_url
    assert_equal 'https://d1u1mce87gyfbn.cloudfront.net/game/playerlevelrewards/' \
                 '0x0250000000000921_Border.png', account.level_url
    assert_equal 2553, account.rank
    assert_equal 92, account.level
  end
end
