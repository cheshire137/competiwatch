class SeasonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account, except: [:index, :choose_season_to_wipe]
  before_action :set_oauth_account_if_battletag, only: :index
  before_action :ensure_oauth_account_is_mine, except: :choose_season_to_wipe
  before_action :set_season, only: [:confirm_wipe, :wipe, :index]

  def choose_season_to_wipe
    @oauth_accounts = current_user.oauth_accounts.order_by_battletag
    @match_counts = current_user.matches.group(:oauth_account_id, :season).count
    @seasons_for_account = @match_counts.keys.inject({}) do |hash, id_and_season|
      oauth_account_id = id_and_season.first
      hash[oauth_account_id] ||= []
      hash[oauth_account_id] << id_and_season.last
      hash
    end
  end

  def confirm_wipe
    @matches = @oauth_account.matches.in_season(@season).includes(:heroes, :map, :friends).
      ordered_by_time
    @match_count = @matches.count
  end

  def wipe
    match_count = @oauth_account.matches.in_season(@season).count
    @oauth_account.matches.in_season(@season).destroy_all
    flash[:notice] = "Removed #{match_count} #{'match'.pluralize(match_count)} for " +
      "#{@oauth_account} in season #{@season}."
    redirect_to matches_path(Match::LATEST_SEASON, @oauth_account)
  end
end
