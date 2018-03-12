module AccountsHelper
  def account_hero_tldr_roles(account_heroes)
    roles = account_heroes.map { |account_hero| account_hero.hero.role }
    role_counts = {}

    roles.each do |role|
      role_counts[role] ||= 0
      role_counts[role] += 1
    end

    role_counts = role_counts.sort_by { |role, count| -count }.to_h
    role_counts.keys.map(&:to_s)
  end

  def account_heroes_tldr(account_heroes)
    account_hero_tldr_roles(account_heroes).map do |role|
      Hero.pretty_role(role)
    end.join(' / ')
  end

  def total_seconds_played(account_heroes)
    account_heroes.select { |account_hero| account_hero.seconds_played }.
      sum { |account_hero| account_hero.seconds_played }
  end

  def max_seconds_played(account_heroes)
    hero_with_seconds_played = account_heroes.detect { |account_hero| account_hero.seconds_played }
    return unless hero_with_seconds_played

    max = hero_with_seconds_played.seconds_played
    account_heroes.each do |account_hero|
      if account_hero.seconds_played && account_hero.seconds_played > max
        max = account_hero.seconds_played
      end
    end
    max
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
