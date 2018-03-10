class SeasonShare < ApplicationRecord
  belongs_to :account

  validates :season, presence: true, uniqueness: { scope: :account_id }
end
