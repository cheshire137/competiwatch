class OAuthAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account, only: [:destroy, :set_default, :show]
  before_action :ensure_oauth_account_is_mine, only: [:destroy, :set_default, :show]

  def index
    @oauth_accounts = current_user.oauth_accounts.includes(:user).order_by_battletag
  end

  def show
    @other_oauth_accounts = current_user.oauth_accounts.order_by_battletag.
      where('battletag <> ?', @oauth_account.battletag)
  end

  def set_default
    current_user.default_oauth_account = @oauth_account

    if current_user.save
      flash[:notice] = "Your default account is now #{@oauth_account}."
    else
      flash[:error] = 'Could not update your default account at this time.'
    end

    redirect_to accounts_path
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
