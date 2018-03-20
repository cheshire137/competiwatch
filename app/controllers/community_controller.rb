class CommunityController < ApplicationController
  before_action :authenticate_user!

  def index
    @top_rank = Account.top_rank
    @bottom_rank = Account.bottom_rank
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
