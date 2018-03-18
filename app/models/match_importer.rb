class MatchImporter
  attr_reader :matches, :errors

  def initialize(account:, season:)
    @account = account
    @season = season
    @matches = []
    @errors = []
  end

  def import(path)
    table = CSV.read(path, headers: true, header_converters: [:downcase],
                     encoding: 'ISO-8859-1')
    @account.wipe_season(@season)
    prior_match = nil
    table.each do |row|
      match = import_match(row, prior_match: prior_match)
      prior_match = if match.persisted?
        match
      end
      @matches << match
    end
  end

  private

  def import_match(row, prior_match:)
    match = @account.matches.new(season: @season, comment: row['comment'],
                                 prior_match: prior_match)

    if (rank = row['rank']).present?
      match.rank = rank.to_i
    end
    if (placement = row['placement']).present?
      match.placement = placement.downcase == 'y'
    end
    if (result = row['result']).present?
      match.result = result
    end
    if (map_name = row['map']).present?
      match.map_id = map_ids_by_name[map_name.downcase]
    end
    if (time = row['time']).present?
      match.time_of_day = time.downcase
    end
    if (day = row['day']).present?
      match.day_of_week = day.downcase
    end
    if (ally_thrower = row['ally thrower']).present?
      match.ally_thrower = ally_thrower.downcase == 'y'
    end
    if (ally_leaver = row['ally leaver']).present?
      match.ally_leaver = ally_leaver.downcase == 'y'
    end
    if (enemy_thrower = row['enemy thrower']).present?
      match.enemy_thrower = enemy_thrower.downcase == 'y'
    end
    if (enemy_leaver = row['enemy leaver']).present?
      match.enemy_leaver = enemy_leaver.downcase == 'y'
    end

    if (friend_name_str = row['group']).present?
      friend_names = split_string(friend_name_str)
      match.set_friends_from_names friend_names
    end

    if (hero_name_str = row['heroes']).present?
      hero_names = split_string(hero_name_str)
      heroes = hero_names.map do |name|
        flat_name = Hero.flatten_name(name)
        heroes_by_name[flat_name]
      end
      match.heroes = heroes.compact
    end

    unless match.save
      errors << match.errors
    end

    match
  end

  def split_string(str)
    list = if str.include?(',')
      str.split(',')
    elsif str.include?(';')
      str.split(';')
    else
      str.split(' ')
    end
    list.map(&:strip)
  end

  def map_ids_by_name
    @map_ids_by_name ||= Map.select([:id, :name]).map { |map| [map.name.downcase, map.id] }.to_h
  end

  def heroes_by_name
    @heroes_by_name ||= Hero.all.map { |hero| [Hero.flatten_name(hero.name), hero] }.to_h
  end
end
