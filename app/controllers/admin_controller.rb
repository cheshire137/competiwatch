class AdminController < ApplicationController
  before_action :require_admin

  def index
    @users = User.order_by_battletag.paginate(page: current_page)
    @oauth_accounts_by_user_id = OauthAccount.order_by_battletag.group_by(&:user_id)
    @seasons = Season.latest_first.select(:number)
    @matches_by_oauth_account_id = Match.select([:season, :oauth_account_id]).
      group_by(&:oauth_account_id)
  end
end
