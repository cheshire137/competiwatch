class SeasonsController < ApplicationController
  before_action :authenticate_user!, except: :show
  before_action :set_oauth_account, except: :choose_season_to_wipe
  before_action :ensure_oauth_account_exists, except: :choose_season_to_wipe
  before_action :ensure_oauth_account_is_mine, except: [:choose_season_to_wipe, :show]
  before_action :set_season, only: [:confirm_wipe, :wipe, :show]
  before_action :ensure_season_is_visible, only: :show

  def show
    @matches = @oauth_account.matches.in_season(@season).
      includes(:prior_match, :heroes, :map, :friends).ordered_by_time

    set_streaks(@matches)
    @longest_win_streak = @matches.map(&:win_streak).compact.max
    @longest_loss_streak = @matches.map(&:loss_streak).compact.max

    @placement_rank = placement_rank_from(@matches, season: @season, oauth_account: @oauth_account)
  end

  def index
    @active_seasons = @oauth_account.active_seasons
    @total_matches = @oauth_account.matches.with_result.count

    matches = @oauth_account.matches.includes(:friends, :heroes).with_result.ordered_by_time

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
    @win_percent = if @total_matches > 0
      (@total_wins / @total_matches.to_f * 100).round(1)
    end

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
    @matches = @oauth_account.matches.in_season(@season).includes(:heroes, :map, :friends).
      ordered_by_time
    @match_count = @matches.count
  end

  def wipe
    match_count = @oauth_account.matches.in_season(@season).count
    @oauth_account.matches.in_season(@season).destroy_all
    flash[:notice] = "Removed #{match_count} #{'match'.pluralize(match_count)} for " +
      "#{@oauth_account} in season #{@season}."
    redirect_to matches_path(Match::LATEST_SEASON, @oauth_account)
  end

  private

  def ensure_season_is_visible
    return if signed_in? && current_user == @oauth_account.user
    return if @oauth_account.season_is_public?(@season)
    render file: Rails.root.join('public', '404.html'), status: :not_found
  end
end
