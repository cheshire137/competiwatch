class OauthAccount < ApplicationRecord
  belongs_to :user

  validates :battletag, presence: true
  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }

  alias_attribute :to_s, :battletag

  has_many :matches

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
