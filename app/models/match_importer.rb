class MatchImporter
  attr_reader :matches

  def initialize(oauth_account:, season:)
    @oauth_account = oauth_account
    @season = season
    @matches = []
  end

  def import(path)
    table = CSV.read(path, headers: true, header_converters: [:downcase])
    @oauth_account.wipe_season(@season)
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
    match = @oauth_account.matches.new(rank: row['rank'].to_i, season: @season,
                                       comment: row['comment'], prior_match: prior_match,
                                       placement: false)

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

    match.save

    if match.persisted? && (hero_name_str = row['heroes']).present?
      hero_names = if hero_name_str.include?(',')
        hero_name_str.split(',')
      else
        hero_name_str.split(' ')
      end
      heroes = hero_names.map do |name|
        flat_name = Hero.flatten_name(name.strip)
        heroes_by_name[flat_name]
      end
      heroes = heroes.compact
      heroes.each { |hero| match.heroes << hero }
    end

    match
  end

  def map_ids_by_name
    @map_ids_by_name ||= Map.select([:id, :name]).map { |map| [map.name.downcase, map.id] }.to_h
  end

  def heroes_by_name
    @heroes_by_name ||= Hero.all.map { |hero| [Hero.flatten_name(hero.name), hero] }.to_h
  end
end
