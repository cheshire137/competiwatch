class MatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account, only: [:index, :create]
  before_action :set_season, only: [:index, :create]
  before_action :set_match, only: [:edit, :update]

  def index
    @maps = get_maps
    @heroes = get_heroes
    @matches = @oauth_account.matches.in_season(@season).includes(:prior_match, :map).
      ordered_by_time
    @latest_match = @matches.last

    placement_log_match = @matches.placement_logs.first
    @placement_rank = if placement_log_match
      placement_log_match.rank
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
      @latest_match = @oauth_account.matches.ordered_by_time.last

      return render('matches/edit')
    end

    redirect_to matches_path(@season, @oauth_account)
  end

  def edit
    @latest_match = @match.oauth_account.matches.ordered_by_time.last
    @maps = get_maps
    @heroes = get_heroes
  end

  def update
    @match.assign_attributes(match_params)
    @match.time = nil if params[:ignore_time]

    unless @match.save
      @maps = get_maps
      @heroes = get_heroes
      @latest_match = @match.oauth_account.matches.ordered_by_time.last

      return render('matches/edit')
    end

    redirect_to matches_path(@match.season, @match.oauth_account)
  end

  private

  def match_params
    params.require(:match).permit(:map_id, :rank, :comment, :prior_match_id, :placement,
                                  :result, :time, :season)
  end

  def set_match
    @match = Match.where(id: params[:id]).first
    unless @match && @match.user == current_user
      render file: Rails.root.join('public', '404.html'), status: :not_found
    end
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
