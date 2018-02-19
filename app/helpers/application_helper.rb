module ApplicationHelper
  def url_with(options = {})
    url_for(params.permit(:battletag, :season).merge(options))
  end

  def is_matches_page?(season, battletag)
    is_page?('matches', 'index') && is_season_page?(season) && is_battletag_page?(battletag)
  end

  def is_trends_page?(season, battletag)
    is_page?('trends', 'index') && is_season_page?(season) && is_battletag_page?(battletag)
  end

  def is_season_page?(season)
    params[:season] == season
  end

  def is_settings_page?
    is_page?('users', 'settings') || is_page?('oauth_accounts', 'index') ||
      is_page?('season_shares', 'index') || is_page?('seasons', 'choose_season_to_wipe') ||
      is_page?('seasons', 'confirm_wipe')
  end

  def is_battletag_page?(battletag)
    params[:battletag] == battletag
  end

  def is_page?(controller, action)
    params[:controller] == controller && params[:action] == action
  end
end
