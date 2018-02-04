module MatchesHelper
  def map_options
    valid_maps = @maps.map { |map| [map.name, map.id] }
    [['Choose a map', '']] + valid_maps
  end
end
