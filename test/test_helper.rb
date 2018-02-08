require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

OmniAuth.config.test_mode = true

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  def mock_bnet_omniauth(uid: nil, battletag: 'SomeUser#1234')
    OmniAuth.config.mock_auth[:bnet] = OmniAuth::AuthHash.new(
      provider: 'bnet',
      uid: uid || "12345#{OauthAccount.count}",
      info: { battletag: battletag }
    )
  end

  def sign_in_as(user)
    mock_bnet_omniauth(battletag: user.battletag)
    post '/users/auth/bnet/callback', params: { battletag: user.battletag }
  end

  def sign_out
    delete logout_path
  end
end
