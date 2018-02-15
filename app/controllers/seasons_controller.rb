class SeasonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account

  def index
    @active_seasons = @oauth_account.active_seasons
    @total_matches = @oauth_account.matches.count
    @heroes = @oauth_account.heroes.group(:id).order_by_name
  end
end
