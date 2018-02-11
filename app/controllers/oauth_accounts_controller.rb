class OauthAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account, only: [:destroy]

  def index
    @oauth_accounts = current_user.oauth_accounts.order_by_battletag
  end

  def destroy
    if @oauth_account.destroy
      flash[:notice] = "Successfully disconnected #{@oauth_account}."
    else
      flash[:error] = "Could not disconnect #{@oauth_account}."
    end
    redirect_to accounts_path
  end
end
