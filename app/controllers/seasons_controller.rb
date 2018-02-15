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
    @match_counts_by_friend = matches.flat_map(&:friends).inject({}) do |hash, friend|
      hash[friend.name] ||= 0
      hash[friend.name] += 1
      hash
    end
    max = @match_counts_by_friend.values.max
    @most_frequent_friends = @match_counts_by_friend.select { |name, count| count == max }.keys

    win_counts_by_friend = matches.select(&:win?).flat_map(&:friends).inject({}) do |hash, friend|
      hash[friend.name] ||= 0
      hash[friend.name] += 1
      hash
    end
    friends_with_more_than_one_match = @match_counts_by_friend.select { |name, count| count > 1 }.keys
    @win_rates_by_friend = friends_with_more_than_one_match.inject({}) do |hash, name|
      friend_wins = win_counts_by_friend[name] || 0
      hash[name] = (friend_wins / @match_counts_by_friend[name].to_f * 100).round
      hash
    end
    max = @win_rates_by_friend.values.max
    @most_winning_friends = @win_rates_by_friend.select { |name, pct| pct == max }.keys

    min = @win_rates_by_friend.values.min
    @most_losing_friends = @win_rates_by_friend.select { |name, pct| pct == min }.keys - @most_winning_friends
  end
end
