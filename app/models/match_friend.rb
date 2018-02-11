class MatchFriend < ApplicationRecord
  MAX_NAME_LENGTH = 30
  MAX_FRIENDS_PER_MATCH = 5

  belongs_to :match
  belongs_to :user
  has_one :oauth_account, through: :match

  validates :name, presence: true, uniqueness: { scope: :match_id },
    length: { maximum: MAX_NAME_LENGTH }
  validate :user_matches_account
  validate :group_size_within_limit

  scope :order_by_name, ->{ order('LOWER(name) ASC') }

  private

  def group_size_within_limit
    return unless match

    group = match.friends
    group = group.where('match_friends.id <> ?', id) if persisted?

    if group.count >= MAX_FRIENDS_PER_MATCH
      errors.add(:match, "already has a full group: you, #{match.friend_names.join(', ')}")
    end
  end

  def user_matches_account
    return unless user && oauth_account

    unless user == oauth_account.user
      errors.add(:user, "must be the owner of account #{oauth_account}")
    end
  end
end
