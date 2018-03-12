class AdminController < ApplicationController
  before_action :require_admin

  def index
    all_users = User.order_by_battletag
    @friend_count = Friend.count
    @match_count = Match.count
    @latest_match = Match.joins(:account).where('accounts.user_id <> ?', current_user.id).
      order(id: :desc).first
    @latest_shared_season = SeasonShare.joins(:account).
      where('accounts.user_id <> ?', current_user.id).order(id: :desc).first
    @new_season = Season.new(number: Season.current_or_latest_number + 1)
    @account_count = Account.count
    @season_share_count = SeasonShare.count
    @active_user_count = all_users.active.count
    @users = all_users.paginate(page: current_page, per_page: 5)
    @friends_by_user_id = Friend.select(:user_id).group_by(&:user_id)
    @accounts_by_user_id = Account.order_by_battletag.group_by(&:user_id)
    @seasons = Season.latest_first
    @matches_by_account_id = Match.select([:season, :account_id]).
      group_by(&:account_id)
    @user_options = [['--', '']] + all_users.map { |user| [user.battletag, user.id] }
    @userless_accounts = Account.without_user.order_by_battletag
    @userless_account_options = [['--', '']] +
      @userless_accounts.map { |account| [account.battletag, account.id] }
    @top_account_heroes = AccountHero.most_played
  end

  def destroy_season
    season = Season.find(params[:season_id])

    if season.destroy
      flash[:notice] = "Successfully deleted season #{season}."
    else
      flash[:error] = "Could not delete season #{season}: " + season.errors.full_messages.join(', ')
    end

    redirect_to admin_path
  end

  def create_season
    season = Season.new
    season.assign_attributes(new_season_params)

    if season.save
      flash[:notice] = "Successfully created season #{season}."
    else
      flash[:error] = "Could not create season #{season}: " + season.errors.full_messages.join(', ')
    end

    redirect_to admin_path
  end

  def update_season
    season = Season.find(params[:season_id])
    season.assign_attributes(season_params)

    if season.save
      flash[:notice] = "Successfully updated season #{season}."
    else
      flash[:error] = "Could not update season #{season}: " + season.errors.full_messages.join(', ')
    end

    redirect_to admin_path
  end

  def update_account
    unless params[:user_id] && params[:account_id]
      flash[:error] = 'Please specify a user and an account.'
      return redirect_to(admin_path)
    end

    user = User.find(params[:user_id])
    account = Account.find(params[:account_id])
    account.user = user

    if account.save
      flash[:notice] = "Successfully tied account #{account} to user #{user}."
    else
      flash[:error] = "Could not tie account #{account} to user #{user}: " +
                      account.errors.full_messages.join(', ')
    end

    redirect_to admin_path
  end

  def merge_users
    unless params[:primary_user_id] && params[:secondary_user_id]
      flash[:error] = 'Please choose a primary and a secondary user.'
      return redirect_to(admin_path)
    end

    secondary_user = User.find(params[:secondary_user_id])
    primary_user = User.find(params[:primary_user_id])

    if secondary_user.merge_with(primary_user)
      flash[:notice] = "Successfully merged user #{secondary_user} with #{primary_user}."
    else
      flash[:error] = "Failed to merge user #{secondary_user} with #{primary_user}."
    end

    redirect_to admin_path
  end

  private

  def new_season_params
    params.require(:create_season).permit([:started_on, :ended_on, :max_rank, :number])
  end

  def season_params
    params.require(:update_season).permit([:started_on, :ended_on, :max_rank])
  end
end
