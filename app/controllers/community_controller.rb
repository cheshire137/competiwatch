class CommunityController < ApplicationController
  def index
    @top_rank = Account.top_rank
    @bottom_rank = Account.bottom_rank
    @average_rank = Account.average_rank
    @top_heroes = Hero.most_played
    @thrower_leaver_percent = Match.thrower_leaver_percent
  end
end
