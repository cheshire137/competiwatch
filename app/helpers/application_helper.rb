module ApplicationHelper
  def url_with(options = {})
    url_for(params.permit(:battletag, :season).merge(options))
  end

  def home_page_path
    if signed_in?
      battletag = params[:battletag] || current_user.to_param
      season = params[:season] || Match::LATEST_SEASON
      url_with(controller: 'matches', action: 'index', battletag: battletag, season: season)
    else
      root_path
    end
  end
end
