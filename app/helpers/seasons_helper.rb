module SeasonsHelper
  def season_switcher_season_path(season)
    if params[:controller] == 'seasons'
      matches_path(battletag: params[:battletag], season: season)
    else
      url_with(season: season)
    end
  end
end
