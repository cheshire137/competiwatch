class Admin::UsersController < ApplicationController
  before_action :require_admin

  def index
    all_users = User.order_by_battletag
    @users = all_users.paginate(page: current_page, per_page: 20)
    @friends_by_user_id = Friend.select(:user_id).group_by(&:user_id)
    @accounts_by_user_id = Account.order_by_battletag.group_by(&:user_id)
    @matches_by_account_id = Match.select([:season, :account_id]).
      group_by(&:account_id)
    @seasons = Season.latest_first
    @user_options = [['--', '']] + all_users.map { |user| [user.battletag, user.id] }
  end

  def merge
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
end
