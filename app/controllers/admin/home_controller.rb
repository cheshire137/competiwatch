class Admin::HomeController < ApplicationController
  before_action :require_admin

  def index
    @user_count = User.count
    @latest_accounts = Account.order(id: :desc).where('user_id <> ?', current_user).limit(5)
    @top_accounts = Match.top_accounts
    @friend_count = Friend.count
    @top_season = Match.top_season
    @match_count = Match.count
    @latest_matches = Match.joins(:account).where('accounts.user_id <> ?', current_user.id).
      order(id: :desc).limit(6)
    @latest_shared_seasons = SeasonShare.joins(:account).
      where('accounts.user_id <> ?', current_user.id).order(id: :desc).limit(5)
    @account_count = Account.count
    @season_share_count = SeasonShare.count
    @active_user_count = User.active.count
    @user_options = [['--', '']] + User.order_by_battletag.map { |user| [user.battletag, user.id] }
    @total_users_with_single_account = User.total_by_account_count(num_accounts: 1)
    @total_accounts_without_matches = Account.without_matches.count
    @total_deletable_accounts = Account.without_matches.sole_accounts.not_recently_updated.count
    @total_without_avatars = Account.without_avatar.count

    seasons = Season.order_by_number.pluck(:number)
    @total_accounts_near_match_limit = 0
    seasons.each do |season|
      @total_accounts_near_match_limit += Account.near_season_match_limit(season).count
    end
  end
end
