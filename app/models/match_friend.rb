class MatchFriend < ApplicationRecord
  MAX_NAME_LENGTH = 30

  belongs_to :match
  belongs_to :user
  has_one :oauth_account, through: :match

  validates :name, presence: true, uniqueness: { scope: :match_id },
    length: { maximum: MAX_NAME_LENGTH }
  validate :user_matches_account

  scope :order_by_name, ->{ order('LOWER(name) ASC') }

  private

  def user_matches_account
    return unless user && oauth_account

    unless user == oauth_account.user
      errors.add(:user, "must be the owner of account #{oauth_account}")
    end
  end
end
