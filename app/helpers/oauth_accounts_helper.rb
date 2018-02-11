module OauthAccountsHelper
  def account_switcher(selected_account)
    render partial: 'oauth_accounts/account_switcher',
           locals: { selected_account: selected_account }
  end

  def oauth_accounts
    current_user.oauth_accounts.order_by_battletag
  end
end
