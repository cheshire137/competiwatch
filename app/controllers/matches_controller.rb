class MatchesController < ApplicationController
  before_action :authenticate_user!, except: :index
  before_action :set_oauth_account, only: [:index, :create]
  before_action :ensure_oauth_account_is_mine, only: :create
  before_action :set_season, only: [:index, :create]
  before_action :set_match, only: [:edit, :update, :destroy]
  before_action :ensure_season_is_visible, only: :index

  def index
    @can_edit = signed_in? && @oauth_account.user == current_user
    @past_season = Season.past?(@season, season: @season_record)
    @future_season = Season.future?(@season, season: @season_record)
    @matches = @oauth_account.matches.in_season(@season).
      includes(:prior_match, :heroes, :map, :friends).ordered_by_time
    set_streaks(@matches)
    @longest_win_streak = @matches.map(&:win_streak).compact.max
    @longest_loss_streak = @matches.map(&:loss_streak).compact.max
    @latest_match = @matches.last
    @placement_rank = placement_rank_from(@matches, season: @season, oauth_account: @oauth_account)

    if @can_edit
      @maps = get_maps
      @heroes_by_role = get_heroes_by_role
      @friends = current_user.friend_names(@season)
      @all_friends = current_user.all_friend_names
      placement = !@oauth_account.finished_placements?(@season)
      @match = @oauth_account.matches.new(prior_match: @latest_match, season: @season,
                                          placement: placement)
    end
  end

  def create
    @match = @oauth_account.matches.new(match_params)
    @match.season = @season

    friend_names = params[:friend_names] || []
    if friend_names.size > MatchFriend::MAX_FRIENDS_PER_MATCH
      flash[:error] = "Cannot have more than #{MatchFriend::MAX_FRIENDS_PER_MATCH} other players in your group."
      return render_edit_on_fail
    end

    return render_edit_on_fail unless @match.save

    @match.set_heroes_from_ids(params[:heroes])
    @match.set_friends_from_names(friend_names)

    redirect_to matches_path(@season, @oauth_account, anchor: "match-row-#{@match.id}")
  end

  def edit
    @latest_match = @match.oauth_account.matches.ordered_by_time.last
    @maps = get_maps
    @heroes_by_role = get_heroes_by_role
    @friends = current_user.friend_names(@match.season)
    @all_friends = current_user.all_friend_names
    @season_record = Season.find_by_number(@match.season)
  end

  def destroy
    season = @match.season
    @oauth_account = @match.oauth_account

    if @match.destroy
      flash[:notice] = "Successfully deleted #{@oauth_account}'s match."
      redirect_to matches_path(season, @oauth_account)
    else
      flash[:error] = 'Could not delete match.'
      render_edit_on_fail
    end
  end

  def update
    @oauth_account = @match.oauth_account
    @match.assign_attributes(match_params)

    friend_names = params[:friend_names] || []
    if friend_names.size > MatchFriend::MAX_FRIENDS_PER_MATCH
      flash[:error] = "Cannot have more than #{MatchFriend::MAX_FRIENDS_PER_MATCH} other players in your group."
      return render_edit_on_fail
    end

    return render_edit_on_fail unless @match.save

    @match.set_heroes_from_ids(params[:heroes])
    @match.set_friends_from_names(friend_names)

    redirect_to matches_path(@match.season, @oauth_account, anchor: "match-row-#{@match.id}")
  end

  private

  def render_edit_on_fail
    @friends = current_user.friend_names(@match.season)
    @all_friends = current_user.all_friend_names
    @maps = get_maps
    @heroes_by_role = get_heroes_by_role
    @latest_match = @oauth_account.matches.ordered_by_time.last
    unless defined? @season_record
      @season_record = Season.find_by_number(@match.season)
    end

    render 'matches/edit'
  end

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

  def get_heroes_by_role
    heroes = Rails.cache.fetch('heroes') { Hero.order(:name) }
    heroes.group_by(&:role).sort_by { |role, _heroes| Hero::ROLE_SORT[role] }.to_h
  end

  def placement_rank_from(matches, season:, oauth_account:)
    placement_log_match = matches.placement_logs.first
    if placement_log_match
      placement_log_match.rank
    else
      last_placement = oauth_account.last_placement_match_in(season)
      last_placement.rank if last_placement
    end
  end
end
