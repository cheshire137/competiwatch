class SeasonSharesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account
  before_action :ensure_oauth_account_exists
  before_action :ensure_oauth_account_is_mine
  before_action :set_season

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
end
