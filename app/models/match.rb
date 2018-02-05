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

  validates :season, presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :rank, presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0,
                    less_than_or_equal_to: MAX_RANK }
  validates :result, inclusion: { in: RESULT_MAPPINGS.keys }, allow_nil: true
  validates :time_of_day, inclusion: { in: TIME_OF_DAY_MAPPINGS.keys }, allow_nil: true
  validates :day_of_week, inclusion: { in: DAY_OF_WEEK_MAPPINGS.keys }, allow_nil: true
  validate :season_same_as_prior_match

  has_one :user, through: :oauth_account
  has_and_belongs_to_many :heroes

  scope :wins, ->{ where(result: RESULT_MAPPINGS[:win]) }
  scope :losses, ->{ where(result: RESULT_MAPPINGS[:loss]) }
  scope :draws, ->{ where(result: RESULT_MAPPINGS[:draw]) }
  scope :placements, ->{ where(placement: true) }
  scope :non_placements, ->{ where(placement: false) }
  scope :in_season, ->(season) { where(season: season) }
  scope :placement_logs, ->{ where(map_id: nil) }
  scope :ordered_by_time, ->{
    order('CASE WHEN time IS NULL THEN created_at ELSE time END')
  }

  def set_heroes_from_ids(hero_ids)
    heroes_to_keep = Hero.where(id: hero_ids)
    heroes_to_remove = heroes - heroes_to_keep

    heroes_to_remove.each do |hero|
      heroes.delete(hero)
    end

    heroes_to_keep.each do |hero|
      self.heroes << hero
    end
  end

  def placement_log?
    map.blank? && persisted?
  end

  def result
    RESULT_MAPPINGS.key(self[:result])
  end

  def result=(name)
    self[:result] = RESULT_MAPPINGS[name.to_sym]
  end

  def win?
    result == :win
  end

  def loss?
    result == :loss
  end

  def draw?
    result == :draw
  end

  def time_of_day
    TIME_OF_DAY_MAPPINGS.key(self[:time_of_day])
  end

  def time_of_day=(name)
    self[:time_of_day] = if name
      TIME_OF_DAY_MAPPINGS[name.to_sym]
    end
  end

  def day_of_week
    DAY_OF_WEEK_MAPPINGS.key(self[:day_of_week])
  end

  def day_of_week=(name)
    self[:day_of_week] = if name
      DAY_OF_WEEK_MAPPINGS[name.to_sym]
    end
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

  def set_time_of_day
    if time.nil?
      self.time_of_day = nil
      return
    end

    return unless user

    Time.use_zone(user.time_zone) do
      cur_hour = time.hour

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
    if time.nil?
      self.day_of_week = nil
      return
    end

    return unless user

    Time.use_zone(user.time_zone) do
      self.day_of_week = if time.saturday? || time.sunday?
        :weekend
      else
        :weekday
      end
    end
  end

  def season_same_as_prior_match
    return unless season && prior_match

    unless prior_match.season == season
      errors.add(:season, 'must be the same as season from prior match')
    end
  end
end
