module ApplicationHelper
  def url_with(options = {})
    url_for(params.permit(:battletag, :season).merge(options))
  end

  def pretty_date(date)
    date.to_formatted_s(:long_ordinal)
  end

  def current_battletag
    if signed_in?
      params[:battletag] || current_user.default_oauth_account.try(:to_param) ||
        current_user.to_param
    else
      params[:battletag]
    end
  end

  def is_matches_page?(season, battletag)
    is_page?('matches', 'index') && is_season_page?(season) && is_battletag_page?(battletag)
  end

  def is_all_seasons_stats_page?
    is_page?('stats', 'all_seasons')
  end

  def is_all_accounts_stats_page?
    is_page?('stats', 'all_accounts')
  end

  def is_stats_page?
    is_page?('stats', 'index')
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
