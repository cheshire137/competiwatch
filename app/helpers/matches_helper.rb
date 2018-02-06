module MatchesHelper
  WIN_COLORS = [[178,212,132], [102,189,125]].freeze
  LOSS_COLORS = [[250,170,124], [246,106,110]].freeze
  NEUTRAL_COLOR = [254,234,138].freeze

  def season_options
    Match::LATEST_SEASON.downto(1).map { |season| ["Season #{season}", season] }
  end

  def result_options
    results = Match::RESULT_MAPPINGS.keys
    results.map { |result| [result.to_s.humanize, result] }
  end

  def time_of_day_emoji(time_of_day)
    return unless time_of_day

    emoji = if time_of_day == :morning
      "🌅"
    elsif time_of_day == :evening
      "🌆"
    elsif time_of_day == :afternoon
      "😎"
    elsif time_of_day == :night
      "🌝"
    end
    content_tag(:span, emoji, class: 'mr-2')
  end

  def day_of_week_emoji(day_of_week)
    return unless day_of_week

    emoji = if day_of_week == :weekday
      "👔"
    elsif day_of_week == :weekend
      "🎉"
    end
    content_tag(:span, emoji, class: 'mr-2')
  end

  def time_of_day_options
    valid_times = Match::TIME_OF_DAY_MAPPINGS.keys
    [['', '']] + valid_times.map { |name| [name.to_s.humanize, name] }
  end

  def day_of_week_options
    valid_days = Match::DAY_OF_WEEK_MAPPINGS.keys
    [['', '']] + valid_days.map { |name| [name.to_s.humanize, name] }
  end

  def map_options(maps)
    valid_maps = maps.map { |map| [map.name, map.id] }
    [['', '']] + valid_maps
  end

  def match_number(index, match, matches)
    first_match = matches.first
    if first_match.placement_log?
      index
    else
      number = index + 1
      prefix = if match.placement?
        'P'
      end
      "#{prefix}#{number}"
    end
  end

  def match_result(match)
    if match.placement_log?
      ''
    else
      match.result.to_s.capitalize[0]
    end
  end

  def match_rank_change(match, matches)
    return '--' if match.placement?
    return '' unless match.prior_match
    match.rank - match.prior_match.rank
  end

  def match_rank_change_style(match, matches)
    return '' if match.placement_log? || match.placement?

    color = if match.draw?
      NEUTRAL_COLOR
    else
      all_ranks = matches.map(&:rank).compact.sort.uniq
      color_range = if match.win?
        WIN_COLORS
      elsif match.loss?
        LOSS_COLORS
      else
        NEUTRAL_COLORS
      end
      gradient = ColorGradient.new(colors: color_range, steps: all_ranks.length)
      rgb_colors = gradient.rgb
      index = all_ranks.index(match.rank)
      rgb_colors[index]
    end

    "background-color: rgb(#{color[0]}, #{color[1]}, #{color[2]})"
  end

  def match_rank_class(match, placement_rank)
    return unless placement_rank && match.rank

    if placement_rank > match.rank
      'worse-than-placement'
    else
      'better-than-placement'
    end
  end

  def match_win_streak_style(match, index, longest_win_streak)
    return '' unless match.win?

    gradient = ColorGradient.new(colors: WIN_COLORS, steps: longest_win_streak)
    rgb_colors = gradient.rgb
    index = (1..longest_win_streak).to_a.index(match.win_streak)
    color = rgb_colors[index]
    "background-color: rgb(#{color[0]}, #{color[1]}, #{color[2]})"
  end

  def match_loss_streak_style(match, index, longest_loss_streak)
    return '' unless match.loss?

    gradient = ColorGradient.new(colors: LOSS_COLORS, steps: longest_loss_streak)
    rgb_colors = gradient.rgb
    index = (1..longest_loss_streak).to_a.index(match.loss_streak)
    color = rgb_colors[index]
    "background-color: rgb(#{color[0]}, #{color[1]}, #{color[2]})"
  end
end
