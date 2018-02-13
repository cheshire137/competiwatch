require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

OmniAuth.config.test_mode = true
DatabaseCleaner.strategy = :transaction

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  setup do
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
  end

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
