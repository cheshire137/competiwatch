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
      season = Season.current_or_latest_number
      matches_path(season, current_account)
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

  def render_404
    render template: 'errors/not_found', status: :not_found, layout: 'errors'
  end

  def set_account
    battletag = Account.battletag_from_param(params[:battletag])
    @account = Account.find_by_battletag(battletag)
    if @account
      SetProfileDataJob.perform_later(@account.id) if @account.out_of_date?
    else
      render_404
    end
  end

  def ensure_account_is_mine
    render_404 unless signed_in? && @account.linked_with?(current_account)
  end

  def redirect_unless_account_is_mine
    redirect_to profile_path(@account) unless signed_in? && @account.linked_with?(current_account)
  end

  def allow_admin_bypass?
    signed_in? && current_account.admin? && params[:admin].present?
  end

  def ensure_season_is_visible
    return if signed_in? && @account.linked_with?(current_account)
    return if @account.season_is_public?(@season)
    return if allow_admin_bypass?
    redirect_to profile_path(@account)
  end

  def require_admin
    render_404 unless signed_in? && current_account.admin?
  end
end
