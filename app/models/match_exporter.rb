class MatchExporter
  def initialize(oauth_account:, season:)
    @oauth_account = oauth_account
    @season = season
  end

  def export
    column_names = ['Rank', 'Map', 'Comment', 'Day', 'Time', 'Heroes', 'Ally Leaver',
                    'Ally Thrower', 'Enemy Leaver', 'Enemy Thrower']

    CSV.generate(headers: true) do |csv|
      csv << column_names

      matches_to_export.each do |match|
        csv << [match.rank, match.map.try(:name), match.comment, match.day_of_week,
                match.time_of_day, match.heroes.map(&:name).join(', '),
                match.ally_leaver_char, match.ally_thrower_char, match.enemy_leaver_char,
                match.enemy_thrower_char]
      end
    end
  end

  private

  def matches_to_export
    @oauth_account.matches.in_season(@season).includes(:prior_match, :heroes, :map).ordered_by_time
  end
end
