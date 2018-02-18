class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected

  def after_sign_in_path_for(resource)
    stored_location = stored_location_for(resource)
    return stored_location if stored_location

    if resource.is_a?(User)
      oauth_account = resource.default_oauth_account || resource.oauth_accounts.first
      matches_path(Match::LATEST_SEASON, oauth_account)
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
    @season = if params[:season]
      params[:season].to_i
    end
  end

  def set_oauth_account
    battletag = User.battletag_from_param(params[:battletag])
    @oauth_account = OauthAccount.find_by_battletag(battletag)
    unless @oauth_account
      render file: Rails.root.join('public', '404.html'), status: :not_found
    end
  end

  def set_oauth_account_if_battletag
    return unless params[:battletag]
    set_oauth_account
  end

  def ensure_oauth_account_is_mine
    return unless @oauth_account
    unless @oauth_account.user == current_user
      render file: Rails.root.join('public', '404.html'), status: :not_found
    end
  end

  def ensure_season_is_visible
    return if signed_in? && current_user == @oauth_account.user
    return if @oauth_account.season_is_public?(@season)
    render file: Rails.root.join('public', '404.html'), status: :not_found
  end
end
