class Season < ApplicationRecord
  LATEST_SEASON_CACHE_KEY = 'latest-season'

  validates :number, :max_rank, presence: true, numericality: { greater_than: 0, only_integer: true }
  validate :starts_later_than_previous_end_date

  has_many :matches, foreign_key: 'season', primary_key: 'number'

  scope :order_by_number, ->{ order(:number) }
  scope :latest_end_date_first, ->{ order(ended_on: :desc) }
  scope :latest_first, ->{ order(number: :desc) }
  scope :not_ended, ->{ where('ended_on IS NULL OR ended_on > ?', Date.current) }
  scope :ended, ->{ where('ended_on < ?', Date.current) }

  after_create :reset_latest_number, if: :saved_change_to_number?

  delegate :to_s, to: :number

  def self.current
    today = Date.current
    where('started_on <= ? AND (ended_on > ? OR ended_on IS NULL)', today, today).first
  end

  def self.current_or_latest_number
    current_number || latest_number
  end

  def self.current_number
    current.try(:number)
  end

  def self.latest_number(skip_cache: false)
    Rails.cache.delete(LATEST_SEASON_CACHE_KEY) if skip_cache

    cached_value = Rails.cache.fetch(LATEST_SEASON_CACHE_KEY)
    return cached_value if cached_value

    season = latest_first.first
    new_value = season.try(:number)
    Rails.cache.write(LATEST_SEASON_CACHE_KEY, new_value) if new_value

    new_value
  end

  def active?
    started? && !ended?
  end

  def past?
    ended?
  end

  def future?
    !started?
  end

  def ended?
    return false if ended_on.nil?
    ended_on <= Date.current
  end

  def started?
    started_on && started_on <= Date.current
  end

  def to_param
    number.to_s
  end

  private

  def reset_latest_number
    return unless number
    latest_number = self.class.latest_number

    if latest_number && number > latest_number
      Rails.cache.delete(LATEST_SEASON_CACHE_KEY)
    end
  end

  def starts_later_than_previous_end_date
    return unless started_on

    previous_season = self.class.latest_end_date_first
    previous_season = previous_season.where('id <> ?', id) if persisted?
    previous_season = previous_season.first
    return unless previous_season

    if previous_season.ended_on && previous_season.ended_on > started_on
      errors.add(:started_on, "must be on or later than #{previous_season.ended_on}")
    end
  end
end
