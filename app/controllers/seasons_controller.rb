class SeasonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account

  def index
    @active_seasons = @oauth_account.active_seasons
    @total_matches = @oauth_account.matches.count
    @heroes = @oauth_account.heroes.group(:id).order_by_name

    matches = @oauth_account.matches.select(:result)
    @total_wins = matches.select(&:win?).size
    @total_losses = matches.select(&:loss?).size
    @total_draws = matches.select(&:draw?).size
    @win_percent = (@total_wins / @total_matches.to_f * 100).round(1)
  end
end
