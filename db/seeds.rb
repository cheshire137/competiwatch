maps_by_type = {
  assault: ['Hanamura', 'Temple of Anubis', 'Volskaya Industries', 'Horizon Lunar Colony'],
  escort: ['Dorado', 'Route 66', 'Watchpoint: Gibraltar', 'Junkertown'],
  hybrid: ['Eichenwalde', 'Hollywood', "King's Row", 'Numbani', 'Blizzard World'],
  control: ['Ilios', 'Lijiang Tower', 'Nepal', 'Oasis']
}

maps_by_type.each do |type, map_names|
  puts "Creating #{type} maps: #{map_names.to_sentence}"
  map_names.each do |name|
    Map.where(name: name, map_type: type).first_or_create
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
