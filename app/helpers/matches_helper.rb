module MatchesHelper
  WIN_COLORS = [[178,212,132], [102,189,125]].freeze
  LOSS_COLORS = [[250,170,124], [246,106,110]].freeze
  NEUTRAL_COLOR = [254,234,138].freeze

  def roles_with_heroes(heroes_by_role, *roles)
    roles.select { |role| heroes_by_role[role].present? }
  end

  def show_season_warning_for?(match, season)
    return false if match.persisted?
    season.past? || season.future?
  end

  def get_match_count_by_group_size(matches)
    match_count_by_group_size = matches.inject({}) do |hash, match|
      key = match.group_size
      hash[key] ||= 0
      hash[key] += 1
      hash
    end
    match_count_by_group_size.sort_by { |group_size, _match_count| group_size }.to_h
  end

  def group_size_summary(matches)
    match_count_by_group_size = get_match_count_by_group_size(matches)
    descriptions = {
      1 => 'solo queuing',
      2 => 'duo queuing',
      3 => '3-stack',
      4 => '4-stack',
      5 => '5-stack',
      6 => '6-stack'
    }
    summaries = []
    match_count_by_group_size.each do |group_size, match_count|
      suffix = if group_size < 3
        safe_join([
          " #{'match'.pluralize(match_count)}",
          '<br>'.html_safe,
          content_tag(:span, descriptions[group_size], class: 'text-small text-gray')
        ])
      else
        safe_join([
          " #{'match'.pluralize(match_count)}",
          '<br>'.html_safe,
          content_tag(:span, "in a #{descriptions[group_size]}", class: 'text-small text-gray')
        ])
      end
      summary = safe_join([
        content_tag(:span, match_count, class: 'text-bold'),
        content_tag(:span, suffix)
      ])
      summaries << content_tag(:div, summary, class: 'text-center')
    end
    safe_join(summaries)
  end

  def win_percent(wins, total)
    if total > 0
      pct = wins / total.to_f * 100
      rounded_to_one = pct.round(1)
      rounded = pct.round
      if rounded == rounded_to_one
        rounded
      else
        rounded_to_one
      end
    end
  end

  def show_match_rank_image?(match)
    return false unless match.rank
    return true if match.placement_log?
    match.prior_match && match.prior_match.rank_tier != match.rank_tier
  end

  def match_form_action(match)
    if match.persisted?
      update_match_path(match.id)
    else
      matches_path(match.season, match.account)
    end
  end

  def match_save_method(match)
    if match.persisted?
      :put
    else
      :post
    end
  end

  def friends_in(matches)
    friend_names = {}
    matches.map do |match|
      match.friends.each do |friend|
        friend_names[friend.name] ||= 1
      end
    end
    friend_names.keys.sort
  end

  def thrower_tooltip(match)
    tooltip = []
    if match.ally_thrower?
      tooltip << "Thrower on my team"
    end
    if match.enemy_thrower?
      tooltip << "Thrower on the enemy team"
    end
    tooltip.join(" + ")
  end

  def leaver_tooltip(match)
    tooltip = []
    if match.ally_leaver?
      tooltip << "Leaver on my team"
    end
    if match.enemy_leaver?
      tooltip << "Leaver on the enemy team"
    end
    tooltip.join(" + ")
  end

  def season_switcher(selected_season, classes: '')
    render partial: 'matches/season_switcher',
           locals: { selected_season: selected_season, classes: classes }
  end

  def match_account_options
    accounts.map { |account| [account.battletag, account.id] }
  end

  def season_options
    Season.latest_number.downto(1).map { |season| ["Season #{season}", season] }.to_h
  end

  def result_options
    results = Match::RESULT_MAPPINGS.keys
    results.map { |result| [result.to_s.humanize, result] }
  end

  def time_of_day_emoji(time_of_day)
    return unless time_of_day
    Match.emoji_for_time_of_day(time_of_day)
  end

  def day_of_week_emoji(day_of_week)
    return unless day_of_week
    Match.emoji_for_day_of_week(day_of_week)
  end

  def time_of_day_options
    valid_times = Match::TIME_OF_DAY_MAPPINGS.keys
    [['', '']] + valid_times.map { |name| [name.to_s.humanize, name] }
  end

  def day_of_week_options
    valid_days = Match::DAY_OF_WEEK_MAPPINGS.keys
    [['', '']] + valid_days.map { |name| [name.to_s.humanize, name] }
  end

  def map_options(maps)
    valid_maps = maps.map { |map| [map.name, map.id] }
    [['Choose a map', '']] + valid_maps
  end

  def placement_count(matches)
    index = 0
    while matches[index] && matches[index].placement?
      index += 1
    end
    index
  end

  def match_number(index, match, matches)
    first_match = matches.first
    total_placements = placement_count(matches)
    if first_match.placement_log?
      index
    else
      number = index + 1
      prefix = ''
      if match.placement?
        prefix = 'P'
      else
        number -= total_placements
      end
      "#{prefix}#{number}"
    end
  end

  def match_result_short(match)
    if match.placement_log?
      ''
    else
      match.result.to_s.capitalize[0]
    end
  end

  def match_result(match)
    classes = if match.win?
      'text-green'
    elsif match.loss?
      'text-red'
    elsif match.draw?
      'text-orange'
    end
    content_tag(:span, match.result.to_s.capitalize, class: classes)
  end

  def match_rank_change(match, matches)
    @rank_changes ||= {}
    return @rank_changes[match] if @rank_changes.key?(match)
    @rank_changes[match] = if match.rank
      prior_match = match.prior_match
      if prior_match
        if prior_match.rank
          match.rank - prior_match.rank
        else
          '--'
        end
      else
        ''
      end
    else
      '--'
    end
  end

  def match_rank_change_style(match, matches)
    return '' if match.placement_log? || match.placement? || match.result.blank? || match.rank.nil?

    color = if match.draw?
      NEUTRAL_COLOR
    else
      win_loss_rank_change_color(match, matches)
    end

    "background-color: rgb(#{color[0]}, #{color[1]}, #{color[2]})"
  end

  def win_loss_rank_change_color(match, matches)
    this_rank_change = match_rank_change(match, matches)
    rank_changes = matches.select { |other_match| match.result == other_match.result }.
      map { |other_match| match_rank_change(other_match, matches) }.
      select { |change| change.present? && change != '--' }.sort.uniq
    color_range = if match.win?
      WIN_COLORS
    else
      LOSS_COLORS.reverse
    end
    gradient = ColorGradient.new(colors: color_range, steps: rank_changes.length)
    rgb_colors = gradient.rgb
    index = rank_changes.index(this_rank_change)
    rgb_colors[index]
  end

  def match_rank_class(match, placement_rank)
    return unless placement_rank && match.rank

    if placement_rank > match.rank
      'worse-than-placement'
    else
      'better-than-placement'
    end
  end

  def match_win_streak_style(match, index, longest_win_streak)
    return '' unless match.win?

    gradient = ColorGradient.new(colors: WIN_COLORS, steps: longest_win_streak)
    rgb_colors = gradient.rgb
    index = (1..longest_win_streak).to_a.index(match.win_streak)
    color = rgb_colors[index]
    "background-color: rgb(#{color[0]}, #{color[1]}, #{color[2]})"
  end

  def match_loss_streak_style(match, index, longest_loss_streak)
    return '' unless match.loss?

    gradient = ColorGradient.new(colors: LOSS_COLORS, steps: longest_loss_streak)
    rgb_colors = gradient.rgb
    index = (1..longest_loss_streak).to_a.index(match.loss_streak)
    color = rgb_colors[index]
    "background-color: rgb(#{color[0]}, #{color[1]}, #{color[2]})"
  end
end
