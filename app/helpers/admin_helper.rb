module AdminHelper
  def get_seasons_with_matches(seasons, account_matches)
    seasons.select do |season|
      account_matches.any? { |match| match.season == season.number }
    end
  end

  def get_season_match_count(season, account_matches)
    account_matches.select { |match| match.season == season.number }.size
  end
end
