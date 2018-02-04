maps_by_type = {
  assault: ['Hanamura', 'Temple of Anubis', 'Volskaya Industries', 'Horizon Lunar Colony'],
  escort: ['Dorado', 'Route 66', 'Watchpoint: Gibraltar', 'Junkertown'],
  hybrid: ['Eichenwalde', 'Hollywood', "King's Row", 'Numbani', 'Blizzard World'],
  control: ['Ilios', 'Lijiang Tower', 'Nepal', 'Oasis']
}

maps_by_type.each do |type, map_names|
  puts "Creating #{type} maps: #{map_names.to_sentence}"
  map_names.each do |name|
    Map.create!(name: name, map_type: type)
  end
end
