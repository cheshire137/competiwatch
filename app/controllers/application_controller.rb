class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected

  def current_page
    if params[:page].present? && params[:page] =~ /\d+/
      params[:page].to_i
    else
      1
    end
  end

  def after_sign_in_path_for(resource)
    stored_location = stored_location_for(resource)
    return stored_location if stored_location

    if resource.is_a?(User)
      oauth_account = resource.default_oauth_account || resource.oauth_accounts.first
      season = Season.current_or_latest_number
      matches_path(season, oauth_account)
    else
      super
    end
  end

  def set_streaks(matches)
    matches_by_id = matches.map { |match| [match.id, match] }.to_h
    matches.each do |match|
      match.win_streak = Match.get_win_streak(match, matches_by_id)
      match.loss_streak = Match.get_loss_streak(match, matches_by_id)
    end
  end

  def set_season
    @season_number = if params[:season]
      params[:season].to_i
    end
    @season = if @season_number
      Season.find_by_number(@season_number)
    end
  end

  def set_oauth_account
    battletag = User.battletag_from_param(params[:battletag])
    @oauth_account = OauthAccount.find_by_battletag(battletag)
    unless @oauth_account
      render file: Rails.root.join('public', '404.html'), status: :not_found
    end
  end

  def ensure_oauth_account_is_mine
    unless @oauth_account.user == current_user
      render file: Rails.root.join('public', '404.html'), status: :not_found
    end
  end

  def ensure_season_is_visible
    return if signed_in? && current_user == @oauth_account.user
    return if @oauth_account.season_is_public?(@season)
    render file: Rails.root.join('public', '404.html'), status: :not_found
  end

  def require_admin
    unless signed_in? && current_user.admin?
      render file: Rails.root.join('public', '404.html'), status: :not_found
    end
  end
end
