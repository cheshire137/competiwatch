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

  def is_battletag_page?(battletag)
    params[:battletag] == battletag
  end

  def is_page?(controller, action)
    params[:controller] == controller && params[:action] == action
  end

  def home_page_path
    if signed_in?
      battletag = params[:battletag] || current_user.default_oauth_account.try(:to_param) ||
        current_user.to_param
      season = params[:season] || Match::LATEST_SEASON
      url_with(controller: 'matches', action: 'index', battletag: battletag, season: season)
    else
      root_path
    end
  end
end
