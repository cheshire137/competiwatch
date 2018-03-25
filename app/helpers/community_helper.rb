module CommunityHelper
  def group_sizes
    1..(Match::MAX_FRIENDS_PER_MATCH + 1)
  end

  def thrower_leaver_description(condition)
    case condition
    when :ally_thrower
      safe_join([
        content_tag(:span, 'with an'),
        content_tag(:strong, 'ally throwing')
      ], ' ')
    when :ally_leaver
      safe_join([
        content_tag(:span, 'where an'),
        content_tag(:strong, 'ally left')
      ], ' ')
    when :enemy_thrower
      safe_join([
        content_tag(:span, 'with an'),
        content_tag(:strong, 'opponent throwing')
      ], ' ')
    when :enemy_leaver
      safe_join([
        content_tag(:span, 'where an'),
        content_tag(:strong, 'opponent left')
      ], ' ')
    else
      condition
    end
  end
end
