class SeasonSharesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account, except: :index
  before_action :ensure_oauth_account_is_mine, except: :index
  before_action :set_season, except: :index

  def index
    @all_seasons = 1..Season.latest_number
    @shared_seasons_by_oauth_account_id = current_user.season_shares.inject({}) do |hash, season_share|
      hash[season_share.oauth_account_id] ||= []
      hash[season_share.oauth_account_id] << season_share.season
      hash
    end
    @oauth_accounts = current_user.oauth_accounts.order_by_battletag
  end

  def create
    season_share = SeasonShare.where(oauth_account: @oauth_account,
                                     season: @season).first_or_initialize

    if season_share.persisted? || season_share.save
      flash[:notice] = "#{@oauth_account}'s season #{@season} can now be viewed by others."
    else
      flash[:error] = "Could not make #{@oauth_account}'s season #{@season} publicly visible."
    end

    redirect_to matches_path(@season, @oauth_account)
  end

  def destroy
    season_share = SeasonShare.where(oauth_account: @oauth_account,
                                     season: @season).first

    if season_share.nil? || season_share.destroy
      flash[:notice] = "#{@oauth_account}'s season #{@season} is now only visible to you."
    else
      flash[:error] = "Could not change #{@oauth_account}'s season #{@season} visibility; it " +
                      'is still publicly visible.'
    end

    redirect_to matches_path(@season, @oauth_account)
  end
end
