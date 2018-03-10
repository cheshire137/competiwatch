require 'test_helper'

class SetAvatarJobTest < ActiveJob::TestCase
  test 'sets avatar_url on the account' do
    oauth_account = create(:oauth_account, avatar_url: nil, battletag: 'MarchHare#11348')

    VCR.use_cassette('ow_api_profile') do
      SetAvatarJob.perform_now(oauth_account.id)
    end

    assert_equal 'https://d1u1mce87gyfbn.cloudfront.net/game/unlocks/0x02500000000013FE.png',
      oauth_account.reload.avatar_url
  end
end
