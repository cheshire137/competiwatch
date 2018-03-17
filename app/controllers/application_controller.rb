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

  def set_account
    battletag = User.battletag_from_param(params[:battletag])
    @account = Account.find_by_battletag(battletag)
    if @account
      SetProfileDataJob.perform_later(@account.id) if @account.out_of_date?
    else
      render file: Rails.root.join('public', '404.html'), status: :not_found
    end
  end

  def ensure_account_is_mine
    unless @account.user == current_user
      render file: Rails.root.join('public', '404.html'), status: :not_found
    end
  end

  def redirect_unless_account_is_mine
    unless @account.user == current_user
      redirect_to profile_path(@account)
    end
  end

  def allow_admin_bypass?
    signed_in? && current_account.admin? && params[:admin].present?
  end

  def ensure_season_is_visible
    return if signed_in? && current_user == @account.user
    return if @account.season_is_public?(@season)
    return if allow_admin_bypass?
    redirect_to profile_path(@account)
  end

  def current_account
    return unless signed_in?
    return @current_account if defined?(@current_account)

    @current_account = if session[:current_account_id]
      Account.find(session[:current_account_id])
    else
      current_user.default_account || current_user.accounts.last
    end
  end
  helper_method :current_account

  def require_admin
    unless signed_in? && current_account.admin?
      render file: Rails.root.join('public', '404.html'), status: :not_found
    end
  end
end
