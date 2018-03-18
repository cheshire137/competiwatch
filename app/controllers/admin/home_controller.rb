class Admin::HomeController < ApplicationController
  before_action :require_admin

  def index
    all_users = User.order_by_battletag
    @latest_account = Account.order(id: :desc).where('user_id <> ?', current_user).first
    @top_accounts = Match.top_accounts
    @top_rank = Account.top_rank
    @friend_count = Friend.count
    @match_count = Match.count
    @latest_matches = Match.joins(:account).where('accounts.user_id <> ?', current_user.id).
      order(id: :desc).limit(5)
    @latest_shared_seasons = SeasonShare.joins(:account).
      where('accounts.user_id <> ?', current_user.id).order(id: :desc).limit(5)
    @new_season = Season.new(number: Season.current_or_latest_number + 1)
    @account_count = Account.count
    @season_share_count = SeasonShare.count
    @active_user_count = all_users.active.count
    @users = all_users.paginate(page: current_page, per_page: 6)
    @friends_by_user_id = Friend.select(:user_id).group_by(&:user_id)
    @accounts_by_user_id = Account.order_by_battletag.group_by(&:user_id)
    @seasons = Season.latest_first
    @matches_by_account_id = Match.select([:season, :account_id]).
      group_by(&:account_id)
    @user_options = [['--', '']] + all_users.map { |user| [user.battletag, user.id] }
    @userless_accounts = Account.without_user.order_by_battletag
    @userless_account_options = [['--', '']] +
      @userless_accounts.map { |account| [account.battletag, account.id] }
    @top_heroes = Hero.most_played
  end
end
