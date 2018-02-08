maps_by_type = {
  assault: ['Hanamura', 'Temple of Anubis', 'Volskaya Industries', 'Horizon Lunar Colony'],
  escort: ['Dorado', 'Route 66', 'Watchpoint: Gibraltar', 'Junkertown'],
  hybrid: ['Eichenwalde', 'Hollywood', "King's Row", 'Numbani', 'Blizzard World'],
  control: ['Ilios', 'Lijiang Tower', 'Nepal', 'Oasis']
}

map_colors_by_name = {
  'Hanamura' => '#f9e4f8',
  'Temple of Anubis' => '#edc28e',
  'Volskaya Industries' => '#b0a9d7',
  'Horizon Lunar Colony' => '#c6c5c0',
  'Dorado' => '#d19267',
  'Route 66' => '#ddbf9f',
  'Watchpoint: Gibraltar' => '#c0a6b5',
  'Junkertown' => '#f4b531',
  'Eichenwalde' => '#a1ad7b',
  'Hollywood' => '#92d8fd',
  "King's Row" => '#a1bfc5',
  'Numbani' => '#cad298',
  'Blizzard World' => '#2aa6fb',
  'Ilios' => '#a0eafd',
  'Lijiang Tower' => '#d3a096',
  'Nepal' => '#deeafe',
  'Oasis' => '#fdf4a6'
}

maps_by_type.each do |type, map_names|
  puts "Creating #{type} maps: #{map_names.to_sentence}"
  map_names.each do |name|
    map = Map.where(name: name).first_or_initialize
    map.map_type = type
    map.color = map_colors_by_name[name]
    map.save if map.new_record? || map.changed?
  end
end

heroes_by_role = {
  healer: ['Mercy', 'Zenyatta', 'Ana', 'Lúcio', 'Moira'],
  defense: ['Symmetra', 'Torbjörn', 'Mei', 'Hanzo', 'Bastion'],
  :'off-tank' => ['D.Va', 'Roadhog', 'Zarya'],
  tank: ['Winston', 'Reinhardt', 'Orisa'],
  hitscan: ['McCree', 'Soldier: 76', 'Widowmaker'],
  DPS: ['Pharah', 'Sombra', 'Reaper', 'Doomfist', 'Junkrat'],
  flanker: ['Genji', 'Tracer']
}

heroes_by_role.each do |role, hero_names|
  puts "Creating #{role} heroes: #{hero_names.to_sentence}"
  hero_names.each do |name|
    Hero.where(name: name, role: role).first_or_create
  end
end
