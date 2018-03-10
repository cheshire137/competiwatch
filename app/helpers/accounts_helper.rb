module AccountsHelper
  def avatar_link_for(account, classes: '')
    if account.avatar_url
      link_to(avatar_image_for(account, classes: classes), profile_path(account),
              class: 'd-inline-block')
    else
      content_tag(:span, '', class: 'js-remote-load',
                  data: { url: avatar_path(account, include_link: 1) })
    end
  end

  def avatar_for(account, classes: '')
    if account.avatar_url
      avatar_image_for(account, classes: classes)
    else
      content_tag(:span, '', class: 'js-remote-load', data: { url: avatar_path(account) })
    end
  end

  def avatar_image_for(account, classes: '')
    classes += ' avatar'
    image_tag(account.avatar_url, class: classes, width: 20)
  end

  def platform_options
    Account::VALID_PLATFORMS.map { |key, label| [label, key] }
  end

  def region_options
    Account::VALID_REGIONS.map { |key, label| [label, key] }
  end

  def account_switcher(selected_account)
    render partial: 'accounts/account_switcher',
           locals: { selected_account: selected_account }
  end

  def account_switcher_url(account)
    if params[:controller] == 'stats'
      if params[:season]
        matches_path(params[:season], account)
      else
        all_seasons_stats_path(account)
      end
    else
      url_with(battletag: account.to_param)
    end
  end

  def accounts
    @accounts ||= current_user.accounts.order_by_battletag
  end

  def default_account_account_options
    accounts.map do |account|
      [account.battletag, account.to_param]
    end
  end
end
