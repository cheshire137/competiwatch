class StatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account, only: :all_seasons
  before_action :ensure_oauth_account_is_mine, only: :all_seasons
  before_action :set_season, only: :all_accounts

  def index
    @active_seasons = current_user.active_seasons
    matches = current_user.matches.includes(:friends, :heroes, :oauth_account).with_result.
      ordered_by_time
    @total_matches = matches.count
    @total_accounts = matches.map(&:oauth_account_id).uniq.size
    @account_battletags = matches.map(&:oauth_account).uniq.map(&:battletag).sort_by(&:downcase)
    @match_counts_by_hero, @max_hero_match_count = get_match_counts_by_hero(matches)
    @lowest_sr, @highest_sr = get_lowest_and_highest_rank(matches)
    @total_wins, @total_losses, @total_draws = get_total_wins_losses_draws(matches)
    @friends, @match_counts_by_friend = get_friends_and_match_counts(matches)
    @most_frequent_match_count = @match_counts_by_friend.values.max
    @most_frequent_friends = @match_counts_by_friend.
      select { |name, count| count == @most_frequent_match_count }.keys
    @win_rates_by_friend = get_win_rates_by_friend(matches, @match_counts_by_friend)
    @most_winning_friends = get_most_winning_friends(@win_rates_by_friend)
    @most_losing_friends = get_most_losing_friends(@win_rates_by_friend, @most_winning_friends)
  end

  def all_seasons
    @active_seasons = @oauth_account.active_seasons
    matches = @oauth_account.matches.includes([:friends, :heroes]).with_result.ordered_by_time
    @total_matches = matches.count
    @match_counts_by_hero, @max_hero_match_count = get_match_counts_by_hero(matches)
    @lowest_sr, @highest_sr = get_lowest_and_highest_rank(matches)
    @total_wins, @total_losses, @total_draws = get_total_wins_losses_draws(matches)
    @friends, @match_counts_by_friend = get_friends_and_match_counts(matches)
    @most_frequent_match_count = @match_counts_by_friend.values.max
    @most_frequent_friends = @match_counts_by_friend.
      select { |name, count| count == @most_frequent_match_count }.keys
    @win_rates_by_friend = get_win_rates_by_friend(matches, @match_counts_by_friend)
    @most_winning_friends = get_most_winning_friends(@win_rates_by_friend)
    @most_losing_friends = get_most_losing_friends(@win_rates_by_friend, @most_winning_friends)
  end

  def all_accounts
    matches = current_user.matches.in_season(@season).includes(:friends, :heroes, :oauth_account).with_result.ordered_by_time
    @total_matches = matches.count
    @total_accounts = matches.map(&:oauth_account_id).uniq.size
    @account_battletags = matches.map(&:oauth_account).uniq.map(&:battletag).sort_by(&:downcase)
    @match_counts_by_hero, @max_hero_match_count = get_match_counts_by_hero(matches)
    @lowest_sr, @highest_sr = get_lowest_and_highest_rank(matches)
    @total_wins, @total_losses, @total_draws = get_total_wins_losses_draws(matches)
    @friends, @match_counts_by_friend = get_friends_and_match_counts(matches)
    @most_frequent_match_count = @match_counts_by_friend.values.max
    @most_frequent_friends = @match_counts_by_friend.
      select { |name, count| count == @most_frequent_match_count }.keys
    @win_rates_by_friend = get_win_rates_by_friend(matches, @match_counts_by_friend)
    @most_winning_friends = get_most_winning_friends(@win_rates_by_friend)
    @most_losing_friends = get_most_losing_friends(@win_rates_by_friend, @most_winning_friends)
  end

  private

  def get_most_losing_friends(win_rates_by_friend, most_winning_friends)
    min = win_rates_by_friend.values.min
    win_rates_by_friend.select { |name, pct| pct == min }.keys - most_winning_friends
  end

  def get_most_winning_friends(win_rates_by_friend)
    max = win_rates_by_friend.values.max
    win_rates_by_friend.select { |name, pct| pct == max }.keys
  end

  def get_lowest_and_highest_rank(matches)
    all_ranks = matches.select { |match| match.season > 1 && match.rank }.map(&:rank).sort
    [all_ranks.min, all_ranks.max]
  end

  def get_win_rates_by_friend(matches, match_counts_by_friend)
    win_counts_by_friend = matches.select(&:win?).flat_map(&:friends).inject({}) do |hash, friend|
      hash[friend.name] ||= 0
      hash[friend.name] += 1
      hash
    end
    friends_with_more_than_one_match = match_counts_by_friend.select { |name, count| count > 1 }.keys
    friends_with_more_than_one_match.inject({}) do |hash, name|
      friend_wins = win_counts_by_friend[name] || 0
      hash[name] = (friend_wins / match_counts_by_friend[name].to_f * 100).round
      hash
    end
  end

  def get_friends_and_match_counts(matches)
    friends_with_dupes = matches.flat_map(&:friends)
    friends = friends_with_dupes.uniq.map(&:name).sort_by(&:downcase)
    match_counts_by_friend = friends_with_dupes.inject({}) do |hash, friend|
      hash[friend.name] ||= 0
      hash[friend.name] += 1
      hash
    end
    [friends, match_counts_by_friend]
  end

  def get_total_wins_losses_draws(matches)
    wins = matches.select(&:win?).size
    losses = matches.select(&:loss?).size
    draws = matches.select(&:draw?).size
    [wins, losses, draws]
  end

  def get_match_counts_by_hero(matches)
    result = matches.inject({}) do |hash, match|
      match.heroes.each do |hero|
        hash[hero] ||= 0
        hash[hero] += 1
      end
      hash
    end
    result = result.sort_by { |_hero, count| -count }.to_h
    max_hero_match_count = result.values.first
    [result, max_hero_match_count]
  end
end
