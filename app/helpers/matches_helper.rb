module MatchesHelper
  def map_options(maps)
    valid_maps = maps.map { |map| [map.name, map.id] }
    [['Choose a map', '']] + valid_maps
  end

  def result_options
    valid_results = Match::RESULT_MAPPINGS.map { |value, key| [value.to_s.capitalize, key] }
    [['Choose result', '']] + valid_results
  end
end
