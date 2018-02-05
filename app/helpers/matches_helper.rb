module MatchesHelper
  WIN_COLORS = [[178,212,132], [102,189,125]].freeze
  LOSS_COLORS = [[246,106,110], [250,170,124]].freeze
  NEUTRAL_COLORS = [[254,234,138]].freeze

  def map_options(maps)
    valid_maps = maps.map { |map| [map.name, map.id] }
    [['Choose a map', '']] + valid_maps
  end

  def result_options
    valid_results = Match::RESULT_MAPPINGS.map { |value, key| [value.to_s.capitalize, key] }
    [['Choose result', '']] + valid_results
  end

  def match_number(index, matches)
    first_match = matches.first
    if first_match.placement_log?
      index
    else
      index + 1
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
    return '' unless match.prior_match
    match.rank - match.prior_match.rank
  end

  def match_rank_change_style(match, matches)
    return '' if match.placement_log?

    all_ranks = matches.map(&:rank).sort.uniq
    color_range = if match.win?
      WIN_COLORS
    elsif match.loss?
      LOSS_COLORS
    else
      NEUTRAL_COLORS
    end
    gradient = ColorGradient.new(colors: color_range, steps: all_ranks.length)
    rgb_colors = gradient.rgb
    min_rank = all_ranks.first
    max_rank = all_ranks.last
    index = all_ranks.index(match.rank)
    color = rgb_colors[index]
    "background-color: rgb(#{color[0]}, #{color[1]}, #{color[2]})"
  end

  def match_rank_class(match, placement_rank)
    if placement_rank > match.rank
      'worse-than-placement'
    else
      'better-than-placement'
    end
  end

  def match_win_streak(match)
    return '' unless match.win? && match.prior_match

    count = 1
    while (prior_match = match.prior_match) && prior_match.win?
      count += 1
      match = prior_match
    end
    count
  end

  def match_loss_streak(match)
    return '' unless match.loss? && match.prior_match

    count = 1
    while (prior_match = match.prior_match) && prior_match.loss?
      count += 1
      match = prior_match
    end
    count
  end
end
