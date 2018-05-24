maps_by_type = {
  assault: ['Hanamura', 'Temple of Anubis', 'Volskaya Industries', 'Horizon Lunar Colony'],
  escort: ['Dorado', 'Route 66', 'Watchpoint: Gibraltar', 'Junkertown', 'Rialto'],
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
  'Oasis' => '#fdf4a6',
  'Rialto' => '#87d0a4'
}

map_first_season_by_name = {
  'Rialto' => 10,
  'Blizzard World' => 9,
  'Oasis' => 3,
  'Horizon Lunar Colony' => 5,
  'Junkertown' => 6,
  'Eichenwalde' => 2
}

maps_by_type.each do |type, map_names|
  puts "Creating #{type} maps: #{map_names.to_sentence}"
  map_names.each do |name|
    map = Map.where(name: name).first_or_initialize
    map.map_type = type
    map.color = map_colors_by_name[name]
    map.first_season = map_first_season_by_name[name] || 1
    map.save! if map.new_record? || map.changed?
  end
end

heroes_by_role = {
  healer: [
    {
      name: 'Mercy',
      first_season: 1
    },
    {
      name: 'Zenyatta',
      first_season: 1
    },
    {
      name: 'Ana',
      first_season: 1
    },
    {
      name: 'Lúcio',
      first_season: 1
    },
    {
      name: 'Moira',
      first_season: 7
    },
    {
      name: 'Brigitte',
      first_season: 10
    }
  ],
  defense: [
    {
      name: 'Symmetra',
      first_season: 1
    },
    {
      name: 'Torbjörn',
      first_season: 1
    },
    {
      name: 'Mei',
      first_season: 1
    },
    {
      name: 'Hanzo',
      first_season: 1
    },
    {
      name: 'Bastion',
      first_season: 1
    }
  ],
  :'off-tank' => [
    {
      name: 'D.Va',
      first_season: 1
    },
    {
      name: 'Roadhog',
      first_season: 1
    },
    {
      name: 'Zarya',
      first_season: 1
    }
  ],
  tank: [
    {
      name: 'Winston',
      first_season: 1
    },
    {
      name: 'Reinhardt',
      first_season: 1
    },
    {
      name: 'Orisa',
      first_season: 4
    }
  ],
  hitscan: [
    {
      name: 'McCree',
      first_season: 1
    },
    {
      name: 'Soldier: 76',
      first_season: 1
    },
    {
      name: 'Widowmaker',
      first_season: 1
    }
  ],
  DPS: [
    {
      name: 'Pharah',
      first_season: 1
    },
    {
      name: 'Reaper',
      first_season: 1
    },
    {
      name: 'Doomfist',
      first_season: 5
    },
    {
      name: 'Junkrat',
      first_season: 1
    }
  ],
  flanker: [
    {
      name: 'Genji',
      first_season: 1
    },
    {
      name: 'Sombra',
      first_season: 2
    },
    {
      name: 'Tracer',
      first_season: 1
    }
  ]
}

heroes_by_role.each do |role, heroes|
  hero_names = heroes.map { |hero| hero[:name] }
  puts "Creating #{role} heroes: #{hero_names.to_sentence}"
  heroes.each do |data|
    hero = Hero.where(name: data[:name]).first_or_initialize
    hero.role = role
    hero.first_season = data[:first_season]
    hero.save! if hero.new_record? || hero.changed?
  end
end

seasons = {
  1 => { max_rank: 100, started_on: '2016-06-28', ended_on: '2016-08-18' },
  2 => { max_rank: 5000, started_on: '2016-09-01', ended_on: '2016-11-24' },
  3 => { max_rank: 5000, started_on: '2016-12-01', ended_on: '2017-02-22' },
  4 => { max_rank: 5000, started_on: '2017-03-01', ended_on: '2017-05-29' },
  5 => { max_rank: 5000, started_on: '2017-05-31', ended_on: '2017-08-29' },
  6 => { max_rank: 5000, started_on: '2017-09-01', ended_on: '2017-10-29' },
  7 => { max_rank: 5000, started_on: '2017-11-01', ended_on: '2017-12-29' },
  8 => { max_rank: 5000, started_on: '2018-01-01', ended_on: '2018-02-25' },
  9 => { max_rank: 5000, started_on: '2018-02-28', ended_on: '2018-04-27' },
  10 => { max_rank: 5000, started_on: '2018-04-30' }
}

seasons.each do |number, data|
  puts "Creating season #{number}"
  season = Season.where(number: number).first_or_initialize
  season.assign_attributes(data)
  season.save! if season.new_record? || season.changed?
end

Season.latest_number(skip_cache: true)
puts "Latest season: #{Season.latest_number}"
