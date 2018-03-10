module AdminHelper
  def any_matches_for_user?(matches_by_oauth_account_id, accounts_for_user)
    account_ids_for_user = accounts_for_user.map(&:id)
    matches_for_user = matches_by_oauth_account_id.select do |oauth_account_id, _matches|
      account_ids_for_user.include?(oauth_account_id)
    end
    matches_for_user.any? { |_oauth_account_id, matches| matches.any? }
  end

  def get_seasons_with_matches(seasons, account_matches)
    seasons.select do |season|
      account_matches.any? { |match| match.season == season.number }
    end
  end

  def get_season_match_count(season, account_matches)
    account_matches.select { |match| match.season == season.number }.size
  end
end
