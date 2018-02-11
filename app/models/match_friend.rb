class MatchFriend < ApplicationRecord
  MAX_FRIEND_LENGTH = 30

  belongs_to :match
  belongs_to :user
  has_one :oauth_account, through: :match

  validates :friend, presence: true, uniqueness: { scope: :match_id },
    length: { maximum: MAX_FRIEND_LENGTH }
  validate :user_matches_account

  private

  def user_matches_account
    return unless user && oauth_account

    unless user == oauth_account.user
      errors.add(:user, "must be the owner of account #{oauth_account}")
    end
  end
end
