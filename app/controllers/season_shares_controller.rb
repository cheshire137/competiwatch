class SeasonSharesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account, except: :index
  before_action :ensure_account_is_mine, except: :index
  before_action :set_season, except: :index

  def index
    @all_seasons = Season.latest_number.downto(1)
    @match_counts = current_user.matches.group(:account_id, :season).count
    @seasons_for_account = @match_counts.keys.inject({}) do |hash, id_and_season|
      account_id = id_and_season.first
      hash[account_id] ||= []
      hash[account_id] << id_and_season.last
      hash
    end
    @shared_seasons_by_account_id = current_user.season_shares.inject({}) do |hash, season_share|
      hash[season_share.account_id] ||= []
      hash[season_share.account_id] << season_share.season
      hash
    end
    @accounts = current_user.accounts.order_by_battletag
  end

  def create
    season_share = SeasonShare.where(account: @account,
                                     season: @season_number).first_or_initialize

    if season_share.persisted? || season_share.save
      flash[:notice] = "#{@account}'s season #{@season} can now be viewed by others and may " +
                       "appear on the Community page."
    else
      flash[:error] = "Could not make #{@account}'s season #{@season} publicly visible."
    end

    redirect_to matches_path(@season, @account)
  end

  def destroy
    season_share = SeasonShare.where(account: @account,
                                     season: @season_number).first

    if season_share.nil? || season_share.destroy
      flash[:notice] = "#{@account}'s season #{@season} is now only visible to you and will not " +
                       "appear on the Community page."
    else
      flash[:error] = "Could not change #{@account}'s season #{@season} visibility; it " +
                      'is still publicly visible.'
    end

    redirect_to matches_path(@season, @account)
  end
end
