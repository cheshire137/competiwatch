module ApplicationHelper
  def url_with(options = {})
    url_for(params.permit(:battletag, :season).merge(options))
  end

  def pretty_date(date)
    date.to_formatted_s(:long_ordinal)
  end

  def current_season_number
    @current_season_number ||= params[:season] || Season.current_or_latest_number
  end

  def current_battletag_param
    return @current_battletag_param if defined?(@current_battletag_param)

    @current_battletag_param = if params[:battletag]
      params[:battletag]
    elsif signed_in?
      current_account.to_param
    end
  end

  def current_battletag
    param_battletag = current_battletag_param
    if param_battletag
      User.battletag_from_param(param_battletag)
    end
  end

  def is_matches_page?(season, battletag)
    return true if is_page?('matches', 'edit')
    is_page?('matches', 'index') && is_season_page?(season) && is_battletag_page?(battletag)
  end

  def is_profile_page?(account = nil)
    return false unless is_page?('accounts', 'show')
    if account
      params[:battletag] == account.to_param
    else
      true
    end
  end

  def is_all_seasons_trends_page?
    is_page?('trends', 'all_seasons')
  end

  def is_all_accounts_trends_page?
    is_page?('trends', 'all_accounts')
  end

  def is_all_seasons_accounts_page?
    is_page?('trends', 'all_seasons_accounts')
  end

  def is_trends_page?(season, battletag)
    is_page?('trends', 'index') && is_season_page?(season) && is_battletag_page?(battletag)
  end

  def is_season_page?(season)
    params[:season] == season
  end

  def is_settings_page?
    is_page?('users', 'settings') || is_page?('accounts', 'index') ||
      is_page?('season_shares', 'index') || is_page?('seasons', 'choose_season_to_wipe') ||
      is_page?('seasons', 'confirm_wipe')
  end

  def is_import_page?(season, battletag)
    is_page?('import', 'index') && is_season_page?(season) && is_battletag_page?(battletag)
  end

  def is_battletag_page?(battletag)
    params[:battletag] == battletag
  end

  def is_page?(controller, action)
    params[:controller] == controller && params[:action] == action
  end
end
