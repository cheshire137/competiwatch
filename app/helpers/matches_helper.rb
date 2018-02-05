module MatchesHelper
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
