class Match < ApplicationRecord
  belongs_to :oauth_account
  belongs_to :map
  belongs_to :season

  validates :rank, presence: true

  has_one :user, through: :oauth_account
end
