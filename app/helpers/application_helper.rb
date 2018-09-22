module ApplicationHelper
  def latest_app_release_url
    [ENV['DESKTOP_REPO_URL'] || '', 'releases/latest'].join('/')
  end

  def authenticated_sitewide_message
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, filter_html: true, no_images: true,
                                       no_styles: true, safe_links_only: true)
    html = markdown.render(ENV['AUTH_SITEWIDE_MESSAGE'])
    html.html_safe
  end

  def remote_load_with_spinner(url)
    content_tag(:div, class: 'js-remote-load', data: { url: url }) do
      content_tag(:div, class: 'text-center') do
        content_tag(:span, nil, class: 'ion spin ion-load-c h1')
      end
    end
  end

  def donate_url
    ENV['DONATE_URL']
  end

  def show_donate_link?
    donate_url.present?
  end

  def url_with(options = {})
    url_for(params.permit(:battletag, :season).merge(options))
  end

  def pretty_date(date)
    date.to_formatted_s(:long_ordinal)
  end

  def pretty_datetime(datetime)
    datetime.in_time_zone.strftime('%B %-d, %Y %l:%M %P %Z')
  end

  def show_admin_controls?
    signed_in? && current_account.admin?
  end

  def is_admin_page?
    ['admin/home', 'admin/users', 'admin/accounts', 'admin/seasons'].include?(params[:controller])
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

  def page_for_account?(account = nil)
    if account
      params[:battletag] == account.to_param
    else
      true
    end
  end

  def is_all_seasons_trends_page?(account = nil)
    return false unless is_page?('trends', 'all_seasons')
    page_for_account?(account)
  end

  def is_all_accounts_trends_page?
    is_page?('trends', 'all_accounts')
  end

  def is_all_seasons_accounts_page?
    is_page?('trends', 'all_seasons_accounts')
  end

  def highlight_trends_tab?
    is_all_accounts_trends_page? || is_all_seasons_accounts_page? ||
      is_all_seasons_trends_page? || is_page?('trends', 'index')
  end

  def is_trends_page?(season, battletag)
    is_page?('trends', 'index') && is_season_page?(season) && is_battletag_page?(battletag)
  end

  def is_season_page?(season)
    if season.is_a?(Season)
      params[:season] == season.number.to_s
    else
      params[:season] == season
    end
  end

  def is_settings_page?
    is_page?('users', 'settings') || is_page?('accounts', 'index') ||
      is_page?('season_shares', 'index') || is_page?('seasons', 'choose_season_to_wipe') ||
      is_page?('seasons', 'confirm_wipe')
  end

  def is_import_page?(season, battletag)
    is_page?('import', 'index') && is_season_page?(season) && is_battletag_page?(battletag)
  end

  def is_battletag_page?(account_or_battletag)
    if account_or_battletag.is_a?(String)
      params[:battletag] == account_or_battletag
    else
      params[:battletag] == account_or_battletag.to_param
    end
  end

  def is_page?(controller, action)
    params[:controller] == controller && params[:action] == action
  end
end
