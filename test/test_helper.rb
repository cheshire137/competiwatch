require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/channels/'
  add_filter '/mailers/'
end
SimpleCov.minimum_coverage 85

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

  def sign_in_as(account)
    mock_bnet_omniauth(uid: account.uid, battletag: account.battletag)
    post '/users/auth/bnet/callback', params: { battletag: account.battletag }
  end

  def sign_out
    delete logout_path
  end
end
