class OAuthAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account, only: [:destroy, :set_default, :show, :update, :avatar]
  before_action :ensure_oauth_account_is_mine, only: [:destroy, :set_default, :show, :update]

  def index
    @oauth_accounts = current_user.oauth_accounts.includes(:user).order_by_battletag
  end

  def avatar
    @profile = @oauth_account.overwatch_api_profile
    render partial: 'oauth_accounts/avatar', layout: false
  end

  def show
    heroes_by_name = Hero.order_by_name.map { |hero| [hero.name, hero] }.to_h
    @profile = @oauth_account.overwatch_api_profile
    @stats = @oauth_account.overwatch_api_stats(heroes_by_name)
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

  def update
    @oauth_account.assign_attributes oauth_account_params

    if @oauth_account.save
      flash[:notice] = "Successfully updated #{@oauth_account}."
    else
      flash[:error] = "Could not update #{@oauth_account}: " +
                      @oauth_account.errors.full_messages.join(', ')
    end

    redirect_to profile_path(@oauth_account)
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

  private

  def oauth_account_params
    params.require(:oauth_account).permit(:platform, :region)
  end
end
