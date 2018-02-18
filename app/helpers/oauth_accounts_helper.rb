module OauthAccountsHelper
  def account_switcher(selected_account)
    render partial: 'oauth_accounts/account_switcher',
           locals: { selected_account: selected_account }
  end

  def account_switcher_url(oauth_account)
    if params[:controller] == 'seasons' && params[:action] == 'index'
      all_seasons_stats_path(oauth_account)
    else
      url_with(battletag: oauth_account.to_param)
    end
  end

  def oauth_accounts
    @oauth_accounts ||= current_user.oauth_accounts.order_by_battletag
  end
end
