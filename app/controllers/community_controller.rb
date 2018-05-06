class CommunityController < ApplicationController
  before_action :authenticate_user!

  def top_profile_icons
    @top_avatar_urls = Account.with_avatar.group(:avatar_url).
      order('count_all DESC').limit(5).count
    render layout: false
  end

  def group_size
    @season_number = Season.current_or_last_number
    @match_counts_by_group_size = Match.match_counts_by_group_size(season: @season_number)
    @group_size_win_percentages = Match.
        group_size_win_percentages(season: @season_number,
                                   match_counts: @match_counts_by_group_size)
    @max_group_size_win_percentage = @group_size_win_percentages.values.max
    render layout: false
  end

  def most_winning_heroes
    @season_number = Season.current_or_last_number
    @match_counts_by_hero_id = Match.match_counts_by_hero_id(season: @season_number)
    @hero_win_percentages = Match.hero_win_percentages(season: @season_number,
                                                       match_counts: @match_counts_by_hero_id)
    @max_hero_win_percentage = @hero_win_percentages.values.max
    visible_count = 5
    heroes = @hero_win_percentages.keys
    @visible_heroes = heroes.take(visible_count)
    @hidden_heroes = heroes.drop(visible_count)
    render layout: false
  end

  def index
    @top_rank = Account.top_rank
    @average_rank = Account.average_rank

    @season_number = Season.current_or_last_number
    @top_heroes = Hero.most_played(season: @season_number)
    @thrower_leaver_percent = Match.thrower_leaver_percent(season: @season_number)
    @weekend_win_percent = Match.weekend_win_percent(season: @season_number)
    @weekday_win_percent = Match.weekday_win_percent(season: @season_number)
    @max_win_percent = if @weekend_win_percent && @weekday_win_percent
      [@weekday_win_percent, @weekend_win_percent].max
    end
    @overall_win_percent = Match.win_percent(season: @season_number)
    @weekday_thrower_leaver_percent = Match.weekday_thrower_leaver_percent(season: @season_number)
    @weekend_thrower_leaver_percent = Match.weekend_thrower_leaver_percent(season: @season_number)
    @max_thrower_leaver_percent = if @weekday_thrower_leaver_percent && @weekend_thrower_leaver_percent
      [@weekday_thrower_leaver_percent, @weekend_thrower_leaver_percent].max
    end

    @rank_tier_win_percentages = Match.rank_tier_win_percentages(season: @season_number)
    @max_rank_tier_win_percentage = @rank_tier_win_percentages.values.max

    @thrower_leaver_win_percentages = Match.thrower_leaver_win_percentages(season: @season_number)
    @max_thrower_leaver_win_percentage = @thrower_leaver_win_percentages.values.max

    @season_shares = SeasonShare.with_matches(@season_number).includes(:account).random_order.
      limit(6)

    map_win_percentages = Match.map_win_percentages(season: @season_number)
    maps = map_win_percentages.keys
    win_rates = map_win_percentages.values
    @highest_win_map = maps.first
    @lowest_win_map = maps.last
    @highest_win_map_pct = win_rates.first
    @lowest_win_map_pct = win_rates.last

    map_draw_percentages = Match.map_draw_percentages(season: @season_number)
    @highest_draw_map = map_draw_percentages.keys.first
    @highest_draw_map_pct = map_draw_percentages.values.first
  end
end
