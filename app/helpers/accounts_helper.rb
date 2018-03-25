module AccountsHelper
  def admin_link_to_account(account)
    link_to_account(account, new_tab: false, url: admin_account_path(account.id))
  end

  def link_to_account(account, new_tab: true, url: nil)
    link_options = {}
    if new_tab
      link_options[:target] = '_blank'
      link_options[:rel] = 'noopener noreferrer'
    end
    url ||= profile_path(account)
    link_to(url, link_options) { account_with_avatar(account) }
  end

  def account_with_avatar(account)
    safe_join([
      avatar_for(account),
      content_tag(:span, account, class: 'text-bold')
    ], ' ')
  end

  def hero_tldr_roles(heroes)
    roles = heroes.map(&:role)
    role_counts = {}

    roles.each do |role|
      role_counts[role] ||= 0
      role_counts[role] += 1
    end

    role_counts = role_counts.sort_by { |role, count| -count }.to_h
    role_counts.keys.map(&:to_s)
  end

  def heroes_tldr(heroes)
    roles = hero_tldr_roles(heroes).map { |role| Hero.pretty_role(role) }
    roles.take(3).join(' / ')
  end

  def avatar_for(account, classes: '')
    return unless account.avatar_url

    classes += ' avatar'
    image_tag(account.avatar_url, class: classes, width: 20)
  end

  def platform_options
    Account::VALID_PLATFORMS.map { |key, label| [label, key] }
  end

  def region_options
    Account::VALID_REGIONS.map { |key, label| [label, key] }
  end

  def account_switcher(selected_account, classes: '')
    render partial: 'accounts/account_switcher',
           locals: { selected_account: selected_account, classes: classes }
  end

  def account_switcher_url(account)
    if params[:controller] == 'trends'
      if params[:season]
        trends_path(params[:season], account)
      else
        all_seasons_trends_path(account)
      end
    else
      url_with(battletag: account.to_param)
    end
  end

  def accounts
    @accounts ||= if signed_in?
      current_user.accounts.order_by_battletag
    else
      []
    end
  end

  def default_account_account_options
    accounts.map do |account|
      [account.battletag, account.to_param]
    end
  end
end
