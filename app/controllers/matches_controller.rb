class MatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account
  before_action :set_season

  def index
    @maps = get_maps
    @heroes = get_heroes
    all_matches = @oauth_account.matches.includes(:prior_match, :map).ordered_by_time
    @latest_match = all_matches.last
    @matches = if @latest_match
      all_matches.in_season(@season)
    else
      []
    end
    @match = @oauth_account.matches.new(time: Time.zone.now,
                                        prior_match: @latest_match, season: @season)
  end

  def create
    @match = @oauth_account.matches.new(match_params)
    @match.season = @season
    @match.time = nil if params[:ignore_time]

    unless @match.save
      @maps = get_maps
      @heroes = get_heroes

      return render('matches/edit')
    end

    redirect_to matches_path(@season, @oauth_account)
  end

  private

  def match_params
    params.require(:match).permit(:map_id, :rank, :comment, :prior_match_id, :placement,
                                  :result, :time)
  end

  def set_oauth_account
    battletag = User.battletag_from_param(params[:battletag])
    @oauth_account = OauthAccount.find_by_battletag(battletag)
    unless @oauth_account
      render file: Rails.root.join('public', '404.html'), status: :not_found
    end
  end

  def set_season
    @season = params[:season].to_i
  end

  def get_maps
    Rails.cache.fetch('maps') { Map.order(:name).select([:id, :name]) }
  end

  def get_heroes
    Rails.cache.fetch('heroes') { Hero.order(:name) }
  end
end
