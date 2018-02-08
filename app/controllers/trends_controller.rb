class TrendsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account
  before_action :set_season
  layout false

  def heroes_chart
    matches = @oauth_account.matches.in_season(@season).includes(:heroes).
      with_heroes.where("result IS NOT NULL")

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

  def time_chart
    matches = @oauth_account.matches.in_season(@season).select([:time_of_day, :result]).
      where("time_of_day IS NOT NULL").where("result IS NOT NULL")

    wins_by_time = Hash.new(0)
    losses_by_time = Hash.new(0)
    draws_by_time = Hash.new(0)

    matches.each do |match|
      if match.win?
        wins_by_time[match.time_of_day] += 1
      elsif match.loss?
        losses_by_time[match.time_of_day] += 1
      elsif match.draw?
        draws_by_time[match.time_of_day] += 1
      end
    end

    times = Match::TIME_OF_DAY_MAPPINGS.keys
    @win_counts = times.map { |time| wins_by_time[time] || 0 }
    @loss_counts = times.map { |time| losses_by_time[time] || 0 }
    @draw_counts = times.map { |time| draws_by_time[time] || 0 }
    @times = times.map do |time|
      emoji = Match.emoji_for_time_of_day(time)
      suffix = time.to_s.humanize
      "#{emoji} #{suffix}"
    end
  end

  def day_chart
    matches = @oauth_account.matches.in_season(@season).select([:day_of_week, :result]).
      where("day_of_week IS NOT NULL").where("result IS NOT NULL")

    wins_by_day = Hash.new(0)
    losses_by_day = Hash.new(0)
    draws_by_day = Hash.new(0)

    matches.each do |match|
      if match.win?
        wins_by_day[match.day_of_week] += 1
      elsif match.loss?
        losses_by_day[match.day_of_week] += 1
      elsif match.draw?
        draws_by_day[match.day_of_week] += 1
      end
    end

    days = Match::DAY_OF_WEEK_MAPPINGS.keys
    @win_counts = days.map { |day| wins_by_day[day] || 0 }
    @loss_counts = days.map { |day| losses_by_day[day] || 0 }
    @draw_counts = days.map { |day| draws_by_day[day] || 0 }
    @days = days.map do |day|
      emoji = Match.emoji_for_day_of_week(day)
      suffix = day.to_s.humanize
      "#{emoji} #{suffix}"
    end
  end

  def per_map_win_loss_chart
    maps_by_id = Map.order(:name).select([:id, :name]).
      map { |map| [map.id, map] }.to_h
    matches = @oauth_account.matches.in_season(@season).select([:map_id, :result]).
      where("result IS NOT NULL")

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

    @map_names = maps_by_id.values.map(&:name)
    map_ids = maps_by_id.keys
    @win_counts = map_ids.map { |map_id| wins_by_map_id[map_id] || 0 }
    @loss_counts = map_ids.map { |map_id| losses_by_map_id[map_id] || 0 }
    @draw_counts = map_ids.map { |map_id| draws_by_map_id[map_id] || 0 }
  end

  def win_loss_chart
    matches = @oauth_account.matches.in_season(@season).group(:result).count
    @win_count = matches[Match::RESULT_MAPPINGS[:win]]
    @loss_count = matches[Match::RESULT_MAPPINGS[:loss]]
    @draw_count = matches[Match::RESULT_MAPPINGS[:draw]]
  end

  def streaks_chart
    matches = @oauth_account.matches.in_season(@season).includes(:prior_match).
      ordered_by_time.to_a
    set_streaks(matches)

    @game_numbers = (1..matches.size).to_a
    @win_streaks = matches.map { |match| match.win_streak || 0 }
    @loss_streaks = matches.map { |match| match.loss_streak || 0 }
  end
end
