class TrendsController < ApplicationController
  before_action :set_oauth_account
  before_action :set_season
  before_action :ensure_season_is_visible

  def index
    win_loss_chart
    @matches = @oauth_account.matches.in_season(@season).
      includes(:prior_match, :heroes, :map, :friends).ordered_by_time
  end

  def group_stats
    matches = @oauth_account.matches.in_season(@season).includes(:friends).with_result

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

  def heroes_chart
    matches = @oauth_account.matches.in_season(@season).includes(:heroes).with_result

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

    hero_names_by_id = hero_names_by_id.
      sort_by { |id, name| Hero.flatten_name(name) }.to_h

    hero_ids = hero_names_by_id.keys
    @win_counts = hero_ids.map { |hero_id| wins_by_hero_id[hero_id] || 0 }
    @loss_counts = hero_ids.map { |hero_id| losses_by_hero_id[hero_id] || 0 }
    @draw_counts = hero_ids.map { |hero_id| draws_by_hero_id[hero_id] || 0 }
    @heroes = hero_names_by_id.values
  end

  def thrower_leaver_chart
    @types = ['Throwers', 'Leavers']
    matches = @oauth_account.matches.in_season(@season).
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

    @allies = @types.map { |type| allies_by_type[type] || 0 }
    @enemies = @types.map { |type| enemies_by_type[type] || 0 }
  end

  def group_member_chart
    matches = @oauth_account.matches.in_season(@season).includes(:friends).with_result

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
    @win_counts = @group_members.map { |group_member| wins_by_group_member[group_member] || 0 }
    @loss_counts = @group_members.map { |group_member| losses_by_group_member[group_member] || 0 }
    @draw_counts = @group_members.map { |group_member| draws_by_group_member[group_member] || 0 }
  end

  def group_size_chart
    matches = @oauth_account.matches.in_season(@season).includes(:friends).
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
    @win_counts = group_sizes.map { |group_size| wins_by_group_size[group_size] || 0 }
    @loss_counts = group_sizes.map { |group_size| losses_by_group_size[group_size] || 0 }
    @draw_counts = group_sizes.map { |group_size| draws_by_group_size[group_size] || 0 }
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
    matches = @oauth_account.matches.in_season(@season).
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

    @win_counts = @day_times.map { |key| wins_by_day_time[key] || 0 }
    @loss_counts = @day_times.map { |key| losses_by_day_time[key] || 0 }
    @draw_counts = @day_times.map { |key| draws_by_day_time[key] || 0 }
  end

  def map_chart
    maps_by_id = Map.order(:name).select([:id, :name]).
      map { |map| [map.id, map] }.to_h
    matches = @oauth_account.matches.in_season(@season).select([:map_id, :result]).
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
    @win_counts = map_ids.map { |map_id| wins_by_map_id[map_id] || 0 }
    @loss_counts = map_ids.map { |map_id| losses_by_map_id[map_id] || 0 }
    @draw_counts = map_ids.map { |map_id| draws_by_map_id[map_id] || 0 }
  end

  def role_chart
    matches = @oauth_account.matches.in_season(@season).includes(:heroes).with_result
    match_counts_by_role = Hash.new(0)

    matches.each do |match|
      match.heroes.each do |hero|
        match_counts_by_role[hero.role] += 1
      end
    end

    @roles = Hero::ROLES
    @match_counts = @roles.map { |role| match_counts_by_role[role] || 0 }
  end

  def streaks_chart
    matches = @oauth_account.matches.in_season(@season).includes(:prior_match).
      ordered_by_time.to_a
    set_streaks(matches)

    @game_numbers = (1..matches.size).to_a
    @win_streaks = matches.map { |match| match.win_streak || 0 }
    @loss_streaks = matches.map { |match| match.loss_streak || 0 }
  end

  private

  def win_loss_chart
    matches = @oauth_account.matches.in_season(@season).group(:result).count
    @win_count = matches[Match::RESULT_MAPPINGS[:win]]
    @loss_count = matches[Match::RESULT_MAPPINGS[:loss]]
    @draw_count = matches[Match::RESULT_MAPPINGS[:draw]]
  end
end
