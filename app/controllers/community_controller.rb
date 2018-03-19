class CommunityController < ApplicationController
  def index
    @top_rank = Account.top_rank
    @bottom_rank = Account.bottom_rank
    @average_rank = Account.average_rank
    @season_number = Season.current_or_last_number
    @top_heroes = Hero.most_played(season: @season_number)
    @thrower_leaver_percent = Match.thrower_leaver_percent(season: @season_number)
  end
end
