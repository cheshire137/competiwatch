class MatchExporter
  def initialize(account:, season:)
    @account = account
    @season = season
  end

  def export
    column_names = ['Rank', 'Map', 'Comment', 'Day', 'Time', 'Heroes', 'Ally Leaver',
                    'Ally Thrower', 'Enemy Leaver', 'Enemy Thrower', 'Group',
                    'Placement', 'Result']
    matches = matches_to_export

    CSV.generate(headers: true) do |csv|
      csv << column_names

      matches.each do |match|
        csv << [match.rank, match.map.try(:name), match.comment, match.day_of_week,
                match.time_of_day, match.hero_names.join(', '),
                match.ally_leaver_char, match.ally_thrower_char, match.enemy_leaver_char,
                match.enemy_thrower_char, match.group_member_names.join(', '),
                match.placement_char, match.result]
      end
    end
  end

  private

  def matches_to_export
    matches = @account.matches.in_season(@season).
      includes(:prior_match, :heroes, :map).ordered_by_time
    Match.prefill_group_members(matches, user: @account.user)
    matches
  end
end
