class MatchExporter
  def initialize(account:, season:)
    @account = account
    @season = season
  end

  def export
    column_names = ['Rank', 'Map', 'Comment', 'Day', 'Time', 'Heroes', 'Ally Leaver',
                    'Ally Thrower', 'Enemy Leaver', 'Enemy Thrower', 'Group',
                    'Placement', 'Result']

    CSV.generate(headers: true) do |csv|
      csv << column_names

      matches_to_export.each do |match|
        csv << [match.rank, match.map.try(:name), match.comment, match.day_of_week,
                match.time_of_day, match.hero_names.join(', '),
                match.ally_leaver_char, match.ally_thrower_char, match.enemy_leaver_char,
                match.enemy_thrower_char, match.friend_names.join(', '),
                match.placement_char, match.result]
      end
    end
  end

  private

  def matches_to_export
    @account.matches.in_season(@season).
      includes(:prior_match, :friends, :heroes, :map).ordered_by_time
  end
end
