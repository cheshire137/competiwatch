module MatchesHelper
  def map_options
    valid_maps = @maps.map { |map| [map.name, map.id] }
    [['Choose a map', '']] + valid_maps
  end

  def result_options
    valid_results = Match::RESULT_MAPPINGS.map { |value, key| [value.to_s.capitalize, key] }
    [['Choose an outcome', '']] + valid_results
  end
end
