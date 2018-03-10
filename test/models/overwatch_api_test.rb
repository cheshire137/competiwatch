require 'test_helper'

class OverwatchAPITest < ActiveSupport::TestCase
  test 'battletag is encoded for URL' do
    api = OverwatchAPI.new(battletag: 'Amélie#1234', region: 'us', platform: 'pc')
    assert_equal '/profile/pc/us/Am%C3%A9lie-1234', api.profile_url
  end
end
