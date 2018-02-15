class SeasonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account

  def index
    @active_seasons = @oauth_account.active_seasons
    @total_matches = @oauth_account.matches.count
    @heroes = @oauth_account.heroes.group(:id).order_by_name

    matches = @oauth_account.matches.includes(:friends)

    @total_wins = matches.select(&:win?).size
    @total_losses = matches.select(&:loss?).size
    @total_draws = matches.select(&:draw?).size
    @win_percent = (@total_wins / @total_matches.to_f * 100).round(1)

    @friends = matches.flat_map(&:friends).uniq.map(&:name).sort_by { |name| name.downcase }
    match_counts_by_friend = matches.flat_map(&:friends).inject({}) do |hash, friend|
      hash[friend.name] ||= 0
      hash[friend.name] += 1
      hash
    end
    max = match_counts_by_friend.values.max
    @most_frequent_friends = match_counts_by_friend.select { |name, count| count == max }.keys
  end
end
