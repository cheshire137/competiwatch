class Season < ApplicationRecord
  validates :number, :max_rank, presence: true, numericality: { greater_than: 0, only_integer: true }

  has_many :matches, foreign_key: 'season', primary_key: 'number'

  scope :order_by_number, ->{ order(:number) }
  scope :latest_first, ->{ order(number: :desc) }

  def self.latest_number
    season = latest_first.first
    season.try(:number)
  end
end
