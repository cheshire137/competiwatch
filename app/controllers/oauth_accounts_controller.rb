class OauthAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account, only: :destroy
  before_action :ensure_oauth_account_exists, only: :destroy
  before_action :ensure_oauth_account_is_mine, only: :destroy

  def index
    @oauth_accounts = current_user.oauth_accounts.includes(:user).order_by_battletag
  end

  def destroy
    unless @oauth_account.can_be_unlinked?
      flash[:error] = "#{@oauth_account} cannot be unlinked from your account."
      return redirect_to(accounts_path)
    end

    @oauth_account.user = nil
    if @oauth_account.save
      flash[:notice] = "Successfully disconnected #{@oauth_account}."
    else
      flash[:error] = "Could not disconnect #{@oauth_account}."
    end
    redirect_to accounts_path
  end
end
