class MatchFriend < ApplicationRecord
  MAX_FRIENDS_PER_MATCH = 5

  belongs_to :match
  belongs_to :friend
  has_one :account, through: :match

  validates :friend_id, uniqueness: { scope: :match_id }
  validate :friend_user_matches_account
  validate :group_size_within_limit

  after_destroy :delete_straggler_friend

  private

  def group_size_within_limit
    return unless match

    group = match.friends
    group = group.where('match_friends.id <> ?', id) if persisted?

    if group.count >= MAX_FRIENDS_PER_MATCH
      errors.add(:match, "already has a full group: you, #{match.friend_names.join(', ')}")
    end
  end

  def friend_user_matches_account
    return unless friend && account

    unless friend.user == account.user
      errors.add(:friend, "must be a friend of the owner of account #{account}")
    end
  end

  def delete_straggler_friend
    friend.destroy if friend && friend.matches.empty?
  end
end
