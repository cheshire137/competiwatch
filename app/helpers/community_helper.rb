module CommunityHelper
  def group_sizes
    1..(Match::MAX_FRIENDS_PER_MATCH + 1)
  end
end
