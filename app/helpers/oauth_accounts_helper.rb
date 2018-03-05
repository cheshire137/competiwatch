module OAuthAccountsHelper
  def platform_options
    OAuthAccount::VALID_PLATFORMS.map { |key, label| [label, key] }
  end

  def region_options
    OAuthAccount::VALID_REGIONS.map { |key, label| [label, key] }
  end

  def account_switcher(selected_account)
    render partial: 'oauth_accounts/account_switcher',
           locals: { selected_account: selected_account }
  end

  def account_switcher_url(oauth_account)
    if params[:controller] == 'stats'
      if params[:season]
        matches_path(params[:season], oauth_account)
      else
        all_seasons_stats_path(oauth_account)
      end
    else
      url_with(battletag: oauth_account.to_param)
    end
  end

  def oauth_accounts
    @oauth_accounts ||= current_user.oauth_accounts.order_by_battletag
  end

  def default_account_oauth_account_options
    oauth_accounts.map do |oauth_account|
      [oauth_account.battletag, oauth_account.to_param]
    end
  end
end
