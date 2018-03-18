class Admin::HomeController < ApplicationController
  before_action :require_admin

  def index
    @user_count = User.count
    @latest_accounts = Account.order(id: :desc).where('user_id <> ?', current_user).limit(5)
    @top_accounts = Match.top_accounts
    @top_rank = Account.top_rank
    @bottom_rank = Account.bottom_rank
    @average_rank = Account.average_rank
    @friend_count = Friend.count
    @top_season = Match.top_season
    @match_count = Match.count
    @latest_matches = Match.joins(:account).where('accounts.user_id <> ?', current_user.id).
      order(id: :desc).limit(5)
    @latest_shared_seasons = SeasonShare.joins(:account).
      where('accounts.user_id <> ?', current_user.id).order(id: :desc).limit(5)
    @account_count = Account.count
    @season_share_count = SeasonShare.count
    @active_user_count = User.active.count
    @user_options = [['--', '']] + User.order_by_battletag.map { |user| [user.battletag, user.id] }
    @top_heroes = Hero.most_played
    @total_users_with_single_account = User.total_by_account_count(num_accounts: 1)
  end
end
