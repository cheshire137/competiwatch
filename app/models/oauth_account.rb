class OauthAccount < ApplicationRecord
  belongs_to :user

  validates :battletag, presence: true
  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }

  alias_attribute :to_s, :battletag

  has_many :matches

  def wipe_season(season)
    matches.in_season(season).destroy_all
  end

  def import(season, path:)
    table = CSV.read(path, headers: true, header_converters: [:downcase])
    map_ids_by_name = Map.select([:id, :name]).
      map { |map| [map.name.downcase, map.id] }.to_h
    heroes_by_name = Hero.all.map { |hero| [Hero.flatten_name(hero.name), hero] }.to_h
    imported_matches = []

    # Wipe existing matches this season
    wipe_season(season)

    prior_match = nil
    table.each do |row|
      match = matches.new(rank: row['rank'].to_i, season: season, comment: row['comment'],
                          prior_match: prior_match, placement: false)
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
        hero_names = hero_name_str.split(',')
        heroes = hero_names.map do |name|
          flat_name = Hero.flatten_name(name.strip)
          heroes_by_name[flat_name]
        end
        heroes = heroes.compact
        heroes.each { |hero| match.heroes << hero }
      end

      prior_match = if match.persisted?
        match
      end
      imported_matches << match
    end

    imported_matches
  end

  def export(season)
    records = matches.in_season(season).includes(:prior_match, :heroes, :map).ordered_by_time
    attributes = ['Rank', 'Map', 'Comment', 'Day', 'Time', 'Heroes', 'Ally Leaver', 'Ally Thrower',
                  'Enemy Leaver', 'Enemy Thrower']

    CSV.generate(headers: true) do |csv|
      csv << attributes

      records.each do |match|
        csv << [match.rank, match.map.try(:name), match.comment, match.day_of_week,
                match.time_of_day, match.heroes.map(&:name).join(', '),
                match.ally_leaver_char, match.ally_thrower_char, match.enemy_leaver_char,
                match.enemy_thrower_char]
      end
    end
  end

  def last_placement_match_in(season)
    matches.in_season(season).placements.with_rank.ordered_by_time.last
  end

  def self.find_by_battletag(battletag)
    where("LOWER(battletag) = ?", battletag.downcase).first
  end

  def finished_placements?(season)
    return @finished_placements if defined? @finished_placements
    season_placement_count = matches.placements.in_season(season).count
    @finished_placements = if season_placement_count >= Match::TOTAL_PLACEMENT_MATCHES
      true
    else
      matches.non_placements.in_season(season).any? &&
        matches.in_season(season).placement_logs.any?
    end
  end

  def any_placements?(season)
    matches.placements.in_season(season).any?
  end

  def to_param
    User.parameterize(battletag)
  end
end
