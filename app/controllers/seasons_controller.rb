class SeasonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account, except: [:choose_season_to_wipe]
  before_action :set_season, only: [:confirm_wipe, :wipe]

  def index
    @active_seasons = @oauth_account.active_seasons
    @total_matches = @oauth_account.matches.count
    @heroes = @oauth_account.heroes.group(:id).order_by_name

    matches = @oauth_account.matches.includes(:friends).ordered_by_time

    all_ranks = matches.select { |match| match.season > 1 }.map(&:rank).sort
    @lowest_sr = all_ranks.min
    @highest_sr = all_ranks.max

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

  def choose_season_to_wipe
    @oauth_accounts = current_user.oauth_accounts.order_by_battletag
    @match_counts = current_user.matches.group(:oauth_account_id, :season).count
    @seasons_for_account = @match_counts.keys.inject({}) do |hash, id_and_season|
      oauth_account_id = id_and_season.first
      hash[oauth_account_id] ||= []
      hash[oauth_account_id] << id_and_season.last
      hash
    end
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
end
