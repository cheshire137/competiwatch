class TrendsController < ApplicationController
  before_action :authenticate_user!, only: [:all_seasons, :all_accounts, :all_seasons_accounts]
  before_action :set_oauth_account, only: [:index, :all_seasons]
  before_action :ensure_oauth_account_is_mine, only: :all_seasons
  before_action :set_season, only: [:index, :all_accounts]
  before_action :ensure_season_is_visible, only: :index

  CAREER_HIGH_CUTOFF = 200

  def index
    @is_owner = signed_in? && @oauth_account.user == current_user
    win_loss_chart
    group_stats
    day_time_chart
    group_member_chart
    heroes_chart
    group_size_chart
    map_chart
    role_chart
    streaks_chart
    thrower_leaver_chart
    career_high_heroes_chart
    season_high_heroes_chart
    @matches = account_matches_in_season.includes(:prior_match, :heroes, :map, :friends).
      ordered_by_time
  end

  def all_seasons_accounts
    @active_seasons = current_user.active_seasons
    @matches = account_matches_in_season.
      includes(:prior_match, :map, :friends, :heroes, :oauth_account).with_result.ordered_by_time
    @total_matches = @matches.count
    @total_accounts = @matches.map(&:oauth_account_id).uniq.size
    @account_battletags = @matches.map(&:oauth_account).uniq.map(&:battletag).sort_by(&:downcase)
    @match_counts_by_hero, @max_hero_match_count = get_match_counts_by_hero(@matches)
    @lowest_sr, @highest_sr = get_lowest_and_highest_rank(@matches)
    @total_wins, @total_losses, @total_draws = get_total_wins_losses_draws(@matches)
    @friends, @match_counts_by_friend = get_friends_and_match_counts(@matches)
    @most_frequent_match_count = @match_counts_by_friend.values.max
    @most_frequent_friends = @match_counts_by_friend.
      select { |name, count| count == @most_frequent_match_count }.keys
    @win_rates_by_friend = get_win_rates_by_friend(@matches, @match_counts_by_friend)
    @most_winning_friends = get_most_winning_friends(@win_rates_by_friend)
    @most_losing_friends = get_most_losing_friends(@win_rates_by_friend, @most_winning_friends)
    win_loss_chart
    role_chart
    day_time_chart
    group_size_chart
    thrower_leaver_chart
    group_member_chart
    map_chart
    career_high_heroes_chart
    heroes_chart
    group_stats
  end

  def all_seasons
    @active_seasons = @oauth_account.active_seasons
    @matches = account_matches_in_season.includes(:friends, :heroes, :prior_match, :map).
      with_result.ordered_by_time
    @total_matches = @matches.count
    @match_counts_by_hero, @max_hero_match_count = get_match_counts_by_hero(@matches)
    @lowest_sr, @highest_sr = get_lowest_and_highest_rank(@matches)
    @total_wins, @total_losses, @total_draws = get_total_wins_losses_draws(@matches)
    @friends, @match_counts_by_friend = get_friends_and_match_counts(@matches)
    @most_frequent_match_count = @match_counts_by_friend.values.max
    @most_frequent_friends = @match_counts_by_friend.
      select { |name, count| count == @most_frequent_match_count }.keys
    @win_rates_by_friend = get_win_rates_by_friend(@matches, @match_counts_by_friend)
    @most_winning_friends = get_most_winning_friends(@win_rates_by_friend)
    @most_losing_friends = get_most_losing_friends(@win_rates_by_friend, @most_winning_friends)
    win_loss_chart
    role_chart
    day_time_chart
    group_size_chart
    thrower_leaver_chart
    group_member_chart
    map_chart
    career_high_heroes_chart
    heroes_chart
    group_stats
  end

  def all_accounts
    @matches = account_matches_in_season.
      includes(:friends, :heroes, :oauth_account, :map, :prior_match).with_result.ordered_by_time
    @total_matches = @matches.count
    @total_accounts = @matches.map(&:oauth_account_id).uniq.size
    @account_battletags = @matches.map(&:oauth_account).uniq.map(&:battletag).sort_by(&:downcase)
    @match_counts_by_hero, @max_hero_match_count = get_match_counts_by_hero(@matches)
    @lowest_sr, @highest_sr = get_lowest_and_highest_rank(@matches)
    @total_wins, @total_losses, @total_draws = get_total_wins_losses_draws(@matches)
    @friends, @match_counts_by_friend = get_friends_and_match_counts(@matches)
    @most_frequent_match_count = @match_counts_by_friend.values.max
    @most_frequent_friends = @match_counts_by_friend.
      select { |name, count| count == @most_frequent_match_count }.keys
    @win_rates_by_friend = get_win_rates_by_friend(@matches, @match_counts_by_friend)
    @most_winning_friends = get_most_winning_friends(@win_rates_by_friend)
    @most_losing_friends = get_most_losing_friends(@win_rates_by_friend, @most_winning_friends)
    win_loss_chart
    role_chart
    day_time_chart
    group_size_chart
    thrower_leaver_chart
    group_member_chart
    map_chart
    season_high_heroes_chart
    heroes_chart
    group_stats
  end

  private

  def match_source
    @match_source ||= @oauth_account ? @oauth_account : current_user
  end

  def account_matches_in_season
    return @account_matches_in_season if @account_matches_in_season
    matches = match_source.matches
    matches = matches.in_season(@season_number) if @season_number
    @account_matches_in_season = matches
  end

  def thrower_leaver_chart
    @thrower_leaver_types = ['Throwers', 'Leavers']
    matches = account_matches_in_season.
      select([:ally_thrower, :ally_leaver, :enemy_thrower, :enemy_leaver]).
      where("ally_thrower IS NOT NULL OR enemy_thrower IS NOT NULL OR " +
            "ally_leaver IS NOT NULL OR enemy_leaver IS NOT NULL")

    allies_by_type = Hash.new(0)
    enemies_by_type = Hash.new(0)

    matches.each do |match|
      allies_by_type['Throwers'] += 1 if match.ally_thrower?
      allies_by_type['Leavers'] += 1 if match.ally_leaver?
      enemies_by_type['Throwers'] += 1 if match.enemy_thrower?
      enemies_by_type['Leavers'] += 1 if match.enemy_leaver?
    end

    @thrower_leaver_allies = @thrower_leaver_types.map { |type| allies_by_type[type] || 0 }
    @thrower_leaver_enemies = @thrower_leaver_types.map { |type| enemies_by_type[type] || 0 }
  end

  def streaks_chart
    matches = account_matches_in_season.includes(:prior_match).
      ordered_by_time.to_a
    set_streaks(matches)

    @game_numbers = (1..matches.size).to_a
    @win_streaks = matches.map { |match| match.win_streak || 0 }
    @loss_streaks = matches.map { |match| match.loss_streak || 0 }
  end

  def role_chart
    matches = account_matches_in_season.includes(:heroes).with_result
    match_counts_by_role = Hash.new(0)

    matches.each do |match|
      match.heroes.each do |hero|
        match_counts_by_role[hero.role] += 1
      end
    end

    @roles = Hero::ROLES
    @role_match_counts = @roles.map { |role| match_counts_by_role[role] || 0 }
  end

  def map_chart
    maps_by_id = Map.order(:name).select([:id, :name]).
      map { |map| [map.id, map] }.to_h
    matches = account_matches_in_season.select([:map_id, :result]).
      with_result

    wins_by_map_id = Hash.new(0)
    losses_by_map_id = Hash.new(0)
    draws_by_map_id = Hash.new(0)

    matches.each do |match|
      if match.win?
        wins_by_map_id[match.map_id] += 1
      elsif match.loss?
        losses_by_map_id[match.map_id] += 1
      elsif match.draw?
        draws_by_map_id[match.map_id] += 1
      end
    end

    @map_names = maps_by_id.values.map(&:chart_label)
    map_ids = maps_by_id.keys
    @map_win_counts = map_ids.map { |map_id| wins_by_map_id[map_id] || 0 }
    @map_loss_counts = map_ids.map { |map_id| losses_by_map_id[map_id] || 0 }
    @map_draw_counts = map_ids.map { |map_id| draws_by_map_id[map_id] || 0 }
  end

  def group_size_chart
    matches = account_matches_in_season.includes(:friends).
      with_result

    wins_by_group_size = Hash.new(0)
    losses_by_group_size = Hash.new(0)
    draws_by_group_size = Hash.new(0)

    matches.each do |match|
      if match.win?
        wins_by_group_size[match.group_size] += 1
      elsif match.loss?
        losses_by_group_size[match.group_size] += 1
      elsif match.draw?
        draws_by_group_size[match.group_size] += 1
      end
    end

    group_sizes = (1..6).to_a
    @group_size_win_counts = group_sizes.map { |group_size| wins_by_group_size[group_size] || 0 }
    @group_size_loss_counts = group_sizes.map { |group_size| losses_by_group_size[group_size] || 0 }
    @group_size_draw_counts = group_sizes.map { |group_size| draws_by_group_size[group_size] || 0 }
    @group_sizes = group_sizes.map do |group_size|
      if group_size == 1
        'Solo'
      elsif group_size == 2
        'Duo'
      else
        "#{group_size}-stack"
      end
    end
  end

  def day_time_chart
    matches = account_matches_in_season.
      select([:time_of_day, :day_of_week, :result]).with_day_and_time.with_result

    wins_by_day_time = Hash.new(0)
    losses_by_day_time = Hash.new(0)
    draws_by_day_time = Hash.new(0)

    matches.each do |match|
      key = match.day_time_summary
      if match.win?
        wins_by_day_time[key] += 1
      elsif match.loss?
        losses_by_day_time[key] += 1
      elsif match.draw?
        draws_by_day_time[key] += 1
      end
    end

    @day_times = []
    Match::DAY_OF_WEEK_MAPPINGS.each_key do |day_of_week|
      Match::TIME_OF_DAY_MAPPINGS.each_key do |time_of_day|
        @day_times << Match.day_time_summary(day_of_week, time_of_day)
      end
    end

    @day_time_win_counts = @day_times.map { |key| wins_by_day_time[key] || 0 }
    @day_time_loss_counts = @day_times.map { |key| losses_by_day_time[key] || 0 }
    @day_time_draw_counts = @day_times.map { |key| draws_by_day_time[key] || 0 }
  end

  def win_loss_chart
    matches = account_matches_in_season.group(:result).count
    @win_count = matches[Match::RESULT_MAPPINGS[:win]]
    @loss_count = matches[Match::RESULT_MAPPINGS[:loss]]
    @draw_count = matches[Match::RESULT_MAPPINGS[:draw]]
  end

  def group_member_chart
    matches = account_matches_in_season.includes(:friends).with_result

    wins_by_group_member = Hash.new(0)
    losses_by_group_member = Hash.new(0)
    draws_by_group_member = Hash.new(0)
    @group_members = []

    matches.each do |match|
      match.friend_names.each do |group_member|
        @group_members << group_member unless @group_members.include?(group_member)
        if match.win?
          wins_by_group_member[group_member] += 1
        elsif match.loss?
          losses_by_group_member[group_member] += 1
        elsif match.draw?
          draws_by_group_member[group_member] += 1
        end
      end
    end

    @group_members = @group_members.sort
    @group_member_win_counts = @group_members.map { |group_member| wins_by_group_member[group_member] || 0 }
    @group_member_loss_counts = @group_members.map { |group_member| losses_by_group_member[group_member] || 0 }
    @group_member_draw_counts = @group_members.map { |group_member| draws_by_group_member[group_member] || 0 }
  end

  def season_high_heroes_chart
    @season_high = match_source.season_high(@season)
    return unless @season_high

    cutoff = @season_high - CAREER_HIGH_CUTOFF
    matches = account_matches_in_season.with_rank.with_result.where('rank >= ?', cutoff).
      includes(:heroes)
    hero_names_by_id, wins_by_hero_id, losses_by_hero_id, draws_by_hero_id =
      wins_losses_draws_by_hero_id(matches)
    hero_names_by_id = hero_names_by_id.
      sort_by { |id, name| Hero.flatten_name(name) }.to_h
    hero_ids = hero_names_by_id.keys
    @season_high_heroes_win_counts = hero_ids.map { |hero_id| wins_by_hero_id[hero_id] || 0 }
    @season_high_heroes_loss_counts = hero_ids.map { |hero_id| losses_by_hero_id[hero_id] || 0 }
    @season_high_heroes_draw_counts = hero_ids.map { |hero_id| draws_by_hero_id[hero_id] || 0 }
    @season_high_heroes = hero_names_by_id.values
  end

  def career_high_heroes_chart
    @career_high = match_source.career_high
    return unless @career_high

    cutoff = @career_high - CAREER_HIGH_CUTOFF
    matches = account_matches_in_season.with_rank.with_result.where('rank >= ?', cutoff).
      includes(:heroes)
    hero_names_by_id, wins_by_hero_id, losses_by_hero_id, draws_by_hero_id =
      wins_losses_draws_by_hero_id(matches)
    hero_names_by_id = hero_names_by_id.
      sort_by { |id, name| Hero.flatten_name(name) }.to_h
    hero_ids = hero_names_by_id.keys
    @career_high_heroes_win_counts = hero_ids.map { |hero_id| wins_by_hero_id[hero_id] || 0 }
    @career_high_heroes_loss_counts = hero_ids.map { |hero_id| losses_by_hero_id[hero_id] || 0 }
    @career_high_heroes_draw_counts = hero_ids.map { |hero_id| draws_by_hero_id[hero_id] || 0 }
    @career_high_heroes = hero_names_by_id.values
  end

  def heroes_chart
    matches = account_matches_in_season.includes(:heroes).with_result
    hero_names_by_id, wins_by_hero_id, losses_by_hero_id, draws_by_hero_id =
      wins_losses_draws_by_hero_id(matches)
    hero_names_by_id = hero_names_by_id.
      sort_by { |id, name| Hero.flatten_name(name) }.to_h
    hero_ids = hero_names_by_id.keys
    @heroes_win_counts = hero_ids.map { |hero_id| wins_by_hero_id[hero_id] || 0 }
    @heroes_loss_counts = hero_ids.map { |hero_id| losses_by_hero_id[hero_id] || 0 }
    @heroes_draw_counts = hero_ids.map { |hero_id| draws_by_hero_id[hero_id] || 0 }
    @heroes = hero_names_by_id.values
  end

  def group_stats
    matches = account_matches_in_season.includes(:friends).with_result

    hasher = ->(hash, match) do
      group_members = match.friend_names
      if group_members.any?
        hash[group_members] ||= 0
        hash[group_members] += 1
      end
      hash
    end

    @wins_by_group_members = matches.select(&:win?).inject({}, &hasher)
    @match_counts_by_group_members = matches.inject({}, &hasher)

    unique_groups = @match_counts_by_group_members.keys.sort
    @win_rates_by_group_members = unique_groups.inject({}) do |hash, friend_names|
      wins = @wins_by_group_members[friend_names] || 0
      total = @match_counts_by_group_members[friend_names]
      hash[friend_names] = (wins / total.to_f * 100).round
      hash
    end

    @match_counts_by_group_members = @match_counts_by_group_members.sort_by do |friend_names, match_count|
      win_rate = @win_rates_by_group_members[friend_names]
      [-match_count, -win_rate, friend_names.size, friend_names.join(',')]
    end.to_h
  end

  def wins_losses_draws_by_hero_id(matches)
    wins_by_hero_id = Hash.new(0)
    losses_by_hero_id = Hash.new(0)
    draws_by_hero_id = Hash.new(0)
    hero_names_by_id = {}

    matches.each do |match|
      match.heroes.each do |hero|
        hero_names_by_id[hero.id] = hero.name

        if match.win?
          wins_by_hero_id[hero.id] ||= 0
          wins_by_hero_id[hero.id] += 1
        elsif match.loss?
          losses_by_hero_id[hero.id] ||= 0
          losses_by_hero_id[hero.id] += 1
        elsif match.draw?
          draws_by_hero_id[hero.id] ||= 0
          draws_by_hero_id[hero.id] += 1
        end
      end
    end

    [hero_names_by_id, wins_by_hero_id, losses_by_hero_id, draws_by_hero_id]
  end

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
