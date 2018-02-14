class MatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account, only: [:index, :create, :wipe_season_select, :confirm_wipe,
                                           :wipe, :export]
  before_action :set_season, only: [:index, :create, :confirm_wipe, :wipe, :export]
  before_action :set_match, only: [:edit, :update]

  def index
    @maps = get_maps
    @heroes = get_heroes
    @friends = current_user.friend_names
    @matches = @oauth_account.matches.in_season(@season).
      includes(:prior_match, :heroes, :map, :friends).ordered_by_time

    set_streaks(@matches)
    @longest_win_streak = @matches.map(&:win_streak).compact.max
    @longest_loss_streak = @matches.map(&:loss_streak).compact.max

    @latest_match = @matches.last

    placement_log_match = @matches.placement_logs.first
    @placement_rank = if placement_log_match
      placement_log_match.rank
    else
      last_placement = @oauth_account.last_placement_match_in(@season)
      last_placement.rank if last_placement
    end

    placement = !@oauth_account.finished_placements?(@season)
    @match = @oauth_account.matches.new(prior_match: @latest_match, season: @season,
                                        placement: placement)
  end

  def create
    @match = @oauth_account.matches.new(match_params)
    @match.season = @season

    friend_names = params[:friend_names] || []
    if friend_names.size > MatchFriend::MAX_FRIENDS_PER_MATCH
      flash[:error] = "Cannot have more than #{MatchFriend::MAX_FRIENDS_PER_MATCH} other players in your group."

      @friends = current_user.friend_names
      @maps = get_maps
      @heroes = get_heroes
      @latest_match = @oauth_account.matches.ordered_by_time.last

      return render('matches/edit')
    end

    unless @match.save
      @friends = current_user.friend_names
      @maps = get_maps
      @heroes = get_heroes
      @latest_match = @oauth_account.matches.ordered_by_time.last

      return render('matches/edit')
    end

    @match.set_heroes_from_ids(params[:heroes])
    @match.set_friends_from_names(friend_names)

    redirect_to matches_path(@season, @oauth_account)
  end

  def edit
    @latest_match = @match.oauth_account.matches.ordered_by_time.last
    @maps = get_maps
    @heroes = get_heroes
    @friends = current_user.friend_names
  end

  def update
    @match.assign_attributes(match_params)

    friend_names = params[:friend_names] || []
    if friend_names.size > MatchFriend::MAX_FRIENDS_PER_MATCH
      flash[:error] = "Cannot have more than #{MatchFriend::MAX_FRIENDS_PER_MATCH} other players in your group."

      @friends = current_user.friend_names
      @maps = get_maps
      @heroes = get_heroes
      @latest_match = @match.oauth_account.matches.ordered_by_time.last

      return render('matches/edit')
    end

    unless @match.save
      @friends = current_user.friend_names
      @maps = get_maps
      @heroes = get_heroes
      @latest_match = @match.oauth_account.matches.ordered_by_time.last

      return render('matches/edit')
    end

    @match.set_heroes_from_ids(params[:heroes])
    @match.set_friends_from_names(friend_names)

    redirect_to matches_path(@match.season, @match.oauth_account)
  end

  def export
    date = Time.now.strftime('%Y-%m-%d')
    filename = "#{@oauth_account.to_param}-season-#{@season}-#{date}.csv"

    respond_to do |format|
      format.csv do
        send_data @oauth_account.export(@season), filename: filename
      end
    end
  end

  def wipe_season_select
  end

  def confirm_wipe
    @match_count = @oauth_account.matches.in_season(@season).count
  end

  def wipe
    match_count = @oauth_account.matches.in_season(@season).count
    @oauth_account.matches.in_season(@season).destroy_all
    flash[:notice] = "Removed #{match_count} #{'match'.pluralize(match_count)} for " +
      "#{@oauth_account} in season #{@season}."
    redirect_to matches_path(Match::LATEST_SEASON, @oauth_account)
  end

  private

  def match_params
    params.require(:match).
      permit(:map_id, :rank, :comment, :prior_match_id, :placement, :result, :time_of_day,
             :day_of_week, :season, :enemy_thrower, :ally_thrower, :enemy_leaver,
             :ally_leaver)
  end

  def set_match
    @match = Match.where(id: params[:id]).first
    unless @match && @match.user == current_user
      render file: Rails.root.join('public', '404.html'), status: :not_found
    end
  end

  def get_maps
    Rails.cache.fetch('maps') { Map.order(:name).select([:id, :name]) }
  end

  def get_heroes
    Rails.cache.fetch('heroes') { Hero.order(:name) }
  end
end
