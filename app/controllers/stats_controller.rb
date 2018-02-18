class StatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account, only: :all_seasons
  before_action :ensure_oauth_account_is_mine, only: :all_seasons
  before_action :set_season, only: :all_accounts

  def all_seasons
    @active_seasons = @oauth_account.active_seasons
    matches = @oauth_account.matches.includes([:friends, :heroes]).with_result.ordered_by_time
    @total_matches = matches.count

    @match_counts_by_hero = matches.inject({}) do |hash, match|
      match.heroes.each do |hero|
        hash[hero] ||= 0
        hash[hero] += 1
      end
      hash
    end
    @match_counts_by_hero = @match_counts_by_hero.sort_by { |_hero, count| -count }.to_h
    @max_hero_match_count = @match_counts_by_hero.values.first

    all_ranks = matches.select { |match| match.season > 1 }.map(&:rank).sort
    @lowest_sr = all_ranks.min
    @highest_sr = all_ranks.max

    @total_wins = matches.select(&:win?).size
    @total_losses = matches.select(&:loss?).size
    @total_draws = matches.select(&:draw?).size

    friends = matches.flat_map(&:friends)
    @friends = friends.uniq.map(&:name).sort_by(&:downcase)
    @match_counts_by_friend = friends.inject({}) do |hash, friend|
      hash[friend.name] ||= 0
      hash[friend.name] += 1
      hash
    end
    @most_frequent_match_count = @match_counts_by_friend.values.max
    @most_frequent_friends = @match_counts_by_friend.
      select { |name, count| count == @most_frequent_match_count }.keys

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

  def all_accounts
    matches = current_user.matches.in_season(@season).includes(:friends, :heroes, :oauth_account).with_result.ordered_by_time
    @total_matches = matches.count
    @total_accounts = matches.map(&:oauth_account_id).uniq.size
    @account_battletags = matches.map(&:oauth_account).uniq.map(&:battletag).sort_by(&:downcase)

    @match_counts_by_hero = matches.inject({}) do |hash, match|
      match.heroes.each do |hero|
        hash[hero] ||= 0
        hash[hero] += 1
      end
      hash
    end
    @match_counts_by_hero = @match_counts_by_hero.sort_by { |_hero, count| -count }.to_h
    @max_hero_match_count = @match_counts_by_hero.values.first

    all_ranks = matches.select { |match| match.season > 1 }.map(&:rank).sort
    @lowest_sr = all_ranks.min
    @highest_sr = all_ranks.max

    @total_wins = matches.select(&:win?).size
    @total_losses = matches.select(&:loss?).size
    @total_draws = matches.select(&:draw?).size

    friends = matches.flat_map(&:friends)
    @friends = friends.uniq.map(&:name).sort_by(&:downcase)
    @match_counts_by_friend = friends.inject({}) do |hash, friend|
      hash[friend.name] ||= 0
      hash[friend.name] += 1
      hash
    end
    @most_frequent_match_count = @match_counts_by_friend.values.max
    @most_frequent_friends = @match_counts_by_friend.
      select { |name, count| count == @most_frequent_match_count }.keys

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
