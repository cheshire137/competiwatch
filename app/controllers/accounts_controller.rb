class AccountsController < ApplicationController
  before_action :authenticate_account!, except: [:avatar, :show]
  before_action :set_account, only: [:destroy, :set_default, :show, :update, :avatar]
  before_action :ensure_account_is_mine, only: [:destroy, :set_default, :update]

  def index
    @accounts = if current_account.parent_account
      current_account.parent_account.linked_accounts.order_by_battletag
    else
      [current_account]
    end
  end

  def show
    @is_owner = signed_in? && (
      @account.parent_account == current_account ||
      @account == current_account
    )
    @heroes = @account.most_played_heroes

    @match_count_by_season = Hash.new(0)
    matches = @account.matches.select(:season).order(season: :desc)
    matches = matches.publicly_shared unless @is_owner
    matches.each do |match|
      @match_count_by_season[match.season] += 1
    end

    @season_shares_by_season = @account.season_shares.group_by(&:season)
  end

  def update
    @account.assign_attributes account_params

    if @account.save
      flash[:notice] = "Successfully updated #{@account}."
    else
      flash[:error] = "Could not update #{@account}: " +
                      @account.errors.full_messages.join(', ')
    end

    redirect_to accounts_path
  end

  def destroy
    unless @account.can_be_unlinked?
      flash[:error] = "#{@account} cannot be unlinked from your account."
      return redirect_to(accounts_path)
    end

    @account.parent_account_id = nil
    if @account.save
      flash[:notice] = "Successfully disconnected #{@account}."
    else
      flash[:error] = "Could not disconnect #{@account}."
    end
    redirect_to accounts_path
  end

  private

  def account_params
    params.require(:account).permit(:platform, :region)
  end
end
