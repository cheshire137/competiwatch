class Match < ApplicationRecord
  RESULT_MAPPINGS = { win: 0, loss: 1, draw: 2 }.freeze
  TIME_OF_DAY_MAPPINGS = { morning: 0, afternoon: 1, evening: 2, night: 3 }.freeze
  DAY_OF_WEEK_MAPPINGS = { weekday: 0, weekend: 1 }.freeze
  MAX_RANK = 5000
  TOTAL_PLACEMENT_MATCHES = 10
  LATEST_SEASON = 8

  belongs_to :oauth_account
  belongs_to :map, required: false
  belongs_to :prior_match, required: false, class_name: 'Match'

  before_validation :set_result
  before_validation :set_time_of_day
  before_validation :set_day_of_week
  before_validation :set_time
  before_validation :set_season

  validates :season, presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :rank, presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0,
                    less_than_or_equal_to: MAX_RANK }
  validates :result, inclusion: { in: RESULT_MAPPINGS.keys }, allow_nil: true
  validates :time_of_day, inclusion: { in: TIME_OF_DAY_MAPPINGS.keys }, allow_nil: true
  validates :day_of_week, inclusion: { in: DAY_OF_WEEK_MAPPINGS.keys }, allow_nil: true

  has_one :user, through: :oauth_account
  has_and_belongs_to_many :heroes

  scope :wins, ->{ where(result: RESULT_MAPPINGS[:win]) }
  scope :losses, ->{ where(result: RESULT_MAPPINGS[:loss]) }
  scope :draws, ->{ where(result: RESULT_MAPPINGS[:draw]) }
  scope :placements, ->{ where(placement: true) }
  scope :non_placements, ->{ where(placement: false) }
  scope :in_season, ->(season) { where(season: season) }
  scope :placement_logs, ->{ where(map_id: nil) }

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

  def set_season
    return unless prior_match

    self.season ||= prior_match.season
  end
end
