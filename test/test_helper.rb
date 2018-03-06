require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'vcr'

ENV['RAILS_ENV'] = 'test'
OmniAuth.config.test_mode = true

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def mock_bnet_omniauth(uid:, battletag:)
    OmniAuth.config.mock_auth[:bnet] = OmniAuth::AuthHash.new(
      provider: 'bnet',
      uid: uid,
      info: { battletag: battletag }
    )
  end

  def sign_in_as(oauth_account)
    mock_bnet_omniauth(uid: oauth_account.uid, battletag: oauth_account.battletag)
    post '/users/auth/bnet/callback', params: { battletag: oauth_account.battletag }
  end

  def sign_out
    delete logout_path
  end
end
