class Match < ApplicationRecord
  RESULT_MAPPINGS = { win: 0, loss: 1, draw: 2 }.freeze
  TIME_OF_DAY_MAPPINGS = { morning: 0, afternoon: 1, evening: 2, night: 3 }.freeze
  DAY_OF_WEEK_MAPPINGS = { weekday: 0, weekend: 1 }.freeze
  MAX_RANK = 5000

  belongs_to :oauth_account
  belongs_to :map
  belongs_to :season
  belongs_to :prior_match, required: false

  before_validation :set_result
  before_validation :set_time_of_day
  before_validation :set_day_of_week
  before_validation :set_time

  validates :rank, presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0,
                    less_than_or_equal_to: MAX_RANK }
  validates :placement, presence: true
  validates :result, presence: true, inclusion: { in: RESULT_MAPPINGS.keys }
  validates :time_of_day, presence: true, inclusion: { in: TIME_OF_DAY_MAPPINGS.keys }
  validates :day_of_week, presence: true, inclusion: { in: DAY_OF_WEEK_MAPPINGS.keys }

  has_one :user, through: :oauth_account

  scope :wins, ->{ where(result: RESULT_MAPPINGS[:win]) }
  scope :losses, ->{ where(result: RESULT_MAPPINGS[:loss]) }
  scope :draws, ->{ where(result: RESULT_MAPPINGS[:draw]) }
  scope :placements, ->{ where(placement: true) }
  scope :non_placements, ->{ where(placement: false) }

  def result
    RESULT_MAPPINGS.key(self[:result])
  end

  def result=(name)
    self[:result] = RESULT_MAPPINGS[name.to_sym]
  end

  def time_of_day
    TIME_OF_DAY_MAPPINGS.key(self[:time_of_day])
  end

  def time_of_day=(name)
    self[:time_of_day] = TIME_OF_DAY_MAPPINGS[name.to_sym]
  end

  def day_of_week
    DAY_OF_WEEK_MAPPINGS.key(self[:day_of_week])
  end

  def day_of_week=(name)
    self[:day_of_week] = DAY_OF_WEEK_MAPPINGS[name.to_sym]
  end

  private

  def set_result
    return if result.present?
    return unless prior_match

    self.result = if prior_match.rank < rank
      :win
    elsif prior_match.rank == rank
      :draw
    else
      :loss
    end
  end

  def set_time
    return if time.present?
    return unless user

    Time.use_zone(user.time_zone) do
      self.time = Time.zone.now
    end
  end

  def set_time_of_day
    return if time_of_day.present?
    return unless user

    Time.use_zone(user.time_zone) do
      cur_hour = Time.zone.now.hour

      self.time_of_day = if cur_hour < 12 && cur_hour >= 4 # 4a - 11:59a
        :morning
      elsif cur_hour >= 12 && cur_hour < 5 # 12p - 4:59p
        :afternoon
      elsif cur_hour >= 5 && cur_hour < 9 # 5p - 8:59p
        :evening
      else # 9p - 3:59a
        :night
      end
    end
  end

  def set_day_of_week
    return if day_of_week.present?
    return unless user

    Time.use_zone(user.time_zone) do
      cur_day = Time.zone.today

      self.day_of_week = if cur_day.saturday? || cur_day.sunday?
        :weekend
      else
        :weekday
      end
    end
  end
end
