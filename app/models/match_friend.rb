class MatchFriend < ApplicationRecord
  belongs_to :match
  has_one :oauth_account, through: :match
  has_one :user, through: :oauth_account

  validates :friend, presence: true, uniqueness: { scope: :match_id }
end
