class AccountHero < ApplicationRecord
  belongs_to :account
  belongs_to :hero

  validates :seconds_played, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
    allow_nil: true
end
