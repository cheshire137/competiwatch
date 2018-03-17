class SeasonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account, except: [:index, :choose_season_to_wipe]
  before_action :set_account_if_battletag, only: :index
  before_action :ensure_account_is_mine, except: :choose_season_to_wipe
  before_action :set_season, only: [:confirm_wipe, :wipe, :index]

  def choose_season_to_wipe
    @accounts = current_user.accounts.order_by_battletag
    @match_counts = current_user.matches.group(:account_id, :season).count
    @seasons_for_account = @match_counts.keys.inject({}) do |hash, id_and_season|
      account_id = id_and_season.first
      hash[account_id] ||= []
      hash[account_id] << id_and_season.last
      hash
    end
  end

  def confirm_wipe
    @matches = @account.matches.in_season(@season).includes(:map).ordered_by_time
    Match.prefill_group_members(@matches, user: @account.user)
    Match.prefill_heroes(@matches)
    @match_count = @matches.count
  end

  def wipe
    match_count = @account.matches.in_season(@season).count
    @account.matches.in_season(@season).destroy_all
    flash[:notice] = "Removed #{match_count} #{'match'.pluralize(match_count)} for " +
      "#{@account} in season #{@season}."
    redirect_to matches_path(@season, @account)
  end
end
