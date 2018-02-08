class TrendsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account
  before_action :set_season
  layout false

  def day_chart
    matches = @oauth_account.matches.in_season(@season).select([:day_of_week, :result])

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
    matches = @oauth_account.matches.in_season(@season).select([:map_id, :result])

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
