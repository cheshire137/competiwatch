class OauthAccountsController < ApplicationController
  before_action :authenticate_user!

  def index
    @oauth_accounts = current_user.oauth_accounts.order_by_battletag
  end
end
