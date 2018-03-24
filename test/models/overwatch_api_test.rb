require 'test_helper'

class OverwatchAPITest < ActiveSupport::TestCase
  test 'battletag is encoded for URL' do
    api = OverwatchAPI.new(battletag: 'Amélie#1234', platform: 'pc')
    assert_equal '/api/v3/u/Am%C3%A9lie-1234/stats?platform=pc', api.profile_url
  end
end
