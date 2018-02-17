class SeasonShare < ApplicationRecord
  belongs_to :oauth_account

  validates :season, presence: true, uniqueness: { scope: :oauth_account_id }
end
