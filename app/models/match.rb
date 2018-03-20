class Match < ApplicationRecord
  RESULT_MAPPINGS = { win: 0, loss: 1, draw: 2 }.freeze
  TIME_OF_DAY_MAPPINGS = { morning: 0, afternoon: 1, evening: 2, night: 3 }.freeze
  DAY_OF_WEEK_MAPPINGS = { weekday: 0, weekend: 1 }.freeze
  MAX_RANK = 5000
  TOTAL_PLACEMENT_MATCHES = 10
  MAX_PER_SEASON = 500
  MAX_FRIENDS_PER_MATCH = 5
  RANK_TIERS = [:bronze, :silver, :gold, :platinum, :diamond, :master, :grandmaster].freeze

  attr_accessor :win_streak, :loss_streak
  attr_writer :group_members

  belongs_to :account
  belongs_to :map, required: false
  belongs_to :prior_match, required: false, class_name: 'Match'

  before_validation :set_result
  after_create :reset_career_high, if: :saved_change_to_rank?
  after_save :delete_straggler_friends_on_save, if: :saved_change_to_group_member_ids?
  after_destroy :delete_straggler_friends_on_destroy
  after_destroy :update_next_match_prior_match

  validates :season, presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :rank, numericality: {
    only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_RANK
  }, allow_nil: true
  validates :result, inclusion: { in: RESULT_MAPPINGS.keys }, allow_nil: true
  validates :time_of_day, inclusion: { in: TIME_OF_DAY_MAPPINGS.keys }, allow_nil: true
  validates :day_of_week, inclusion: { in: DAY_OF_WEEK_MAPPINGS.keys }, allow_nil: true
  validate :season_same_as_prior_match
  validate :rank_or_placement
  validate :account_has_not_met_season_limit
  validate :friend_user_matches_account
  validate :group_size_within_limit
  validate :hero_ids_exist

  has_one :user, through: :account

  scope :wins, ->{ where(result: RESULT_MAPPINGS[:win]) }
  scope :losses, ->{ where(result: RESULT_MAPPINGS[:loss]) }
  scope :draws, ->{ where(result: RESULT_MAPPINGS[:draw]) }
  scope :not_draws, ->{ where(result: [RESULT_MAPPINGS[:win], RESULT_MAPPINGS[:loss]]) }
  scope :placements, ->{ where(placement: true) }
  scope :non_placements, ->{ where('placement IS NULL OR placement = ?', false) }
  scope :in_season, ->(season) {
    if season.is_a?(Season)
      where(season: season.number)
    else
      where(season: season)
    end
  }
  scope :placement_logs, ->{
    where('placement IS NULL OR placement = ?', false).where(map_id: nil, prior_match: nil)
  }
  scope :weekends, ->{ where(day_of_week: DAY_OF_WEEK_MAPPINGS[:weekend]) }
  scope :weekdays, ->{ where(day_of_week: DAY_OF_WEEK_MAPPINGS[:weekday]) }
  scope :ordered_by_time, ->{ order(created_at: :asc) }
  scope :with_rank, ->{ where('matches.rank IS NOT NULL') }
  scope :with_result, ->{ where('result IS NOT NULL') }
  scope :with_day_and_time, ->{ where('time_of_day IS NOT NULL AND day_of_week IS NOT NULL') }
  scope :publicly_shared, ->{
    joins("INNER JOIN season_shares ON season_shares.season = matches.season " \
          "AND season_shares.account_id = matches.account_id")
  }
  scope :with_group_members, ->(friends_or_ids) {
    friend_ids = friends_or_ids.map do |friend_or_id|
      friend_or_id.is_a?(Friend) ? friend_or_id.id : friend_or_id
    end
    where('group_member_ids @> ARRAY[?]::integer[]', friend_ids)
  }
  scope :with_group_member, ->(friend_or_id) { with_group_members([friend_or_id]) }
  scope :with_thrower_or_leaver, -> do
    where('enemy_thrower = ? OR ally_thrower = ? OR enemy_leaver = ? OR ally_leaver = ?',
          true, true, true, true)
  end

  # Public: Returns a hash of Account => Integer for the accounts with the most matches.
  def self.top_accounts(limit: 5)
    counts_by_id = group(:account_id).order('COUNT(*) DESC').limit(limit).count
    accounts_by_id = Account.where(id: counts_by_id.keys).
      map { |account| [account.id, account] }.to_h
    counts_by_id.map { |id, count| [accounts_by_id[id], count] }.to_h
  end

  # Public: Returns an array with the number of the season with the most matches logged in it,
  # and the number of matches.
  def self.top_season
    group(:season).count.sort_by { |_season, match_count| -match_count }.first
  end

  def self.weekday_win_percent(season: nil)
    total_matches = Match.with_result.weekdays
    total_matches = total_matches.in_season(season) if season
    total_matches = total_matches.count
    return if total_matches < 1

    win_count = Match.wins.weekdays
    win_count = win_count.in_season(season) if season
    win_count = win_count.count

    percent = (win_count.to_f / total_matches) * 100
    percent.round
  end

  def self.weekend_win_percent(season: nil)
    total_matches = Match.with_result.weekends
    total_matches = total_matches.in_season(season) if season
    total_matches = total_matches.count
    return if total_matches < 1

    win_count = Match.wins.weekends
    win_count = win_count.in_season(season) if season
    win_count = win_count.count

    percent = (win_count.to_f / total_matches) * 100
    percent.round
  end

  def self.thrower_leaver_percent(season: nil)
    total_matches = Match.with_result
    total_matches = total_matches.in_season(season) if season
    total_matches = total_matches.count
    return if total_matches < 1

    thrower_leaver_match_count = Match.with_result.with_thrower_or_leaver
    thrower_leaver_match_count = thrower_leaver_match_count.in_season(season) if season
    thrower_leaver_match_count = thrower_leaver_match_count.count

    percent = (thrower_leaver_match_count.to_f / total_matches) * 100
    percent.round
  end

  def self.rank_tier(rank)
    if rank < 1500
      :bronze
    elsif rank < 2000
      :silver
    elsif rank < 2500
      :gold
    elsif rank < 3000
      :platinum
    elsif rank < 3500
      :diamond
    elsif rank < 4000
      :master
    else
      :grandmaster
    end
  end

  def self.count_by_hero_id(scope: nil)
    matches_played_by_hero_id = Hash.new(0)
    matches = (scope || Match).select(:hero_ids)
    matches.each do |match|
      match.hero_ids.each do |hero_id|
        matches_played_by_hero_id[hero_id] += 1
      end
    end
    matches_played_by_hero_id.sort_by { |_hero_id, match_count| -match_count }.to_h
  end

  def self.prefill_heroes(matches)
    heroes_by_id = Hero.order_by_name.map { |hero| [hero.id, hero] }.to_h
    ids_in_order = heroes_by_id.keys
    matches.each do |match|
      heroes_by_id_for_match = heroes_by_id.slice(*match.hero_ids).
        sort_by { |id, _hero| ids_in_order.index(id) }.to_h
      match.heroes = heroes_by_id_for_match.values
    end
  end

  def heroes
    @heroes ||= Hero.where(id: hero_ids).order_by_name
  end

  def heroes=(list)
    @heroes = list
    self.hero_ids = list.map(&:id)
  end

  def self.prefill_group_members(matches, user:)
    friends_by_id = user.friends.order_by_name.map { |friend| [friend.id, friend] }.to_h
    ids_in_order = friends_by_id.keys
    matches.each do |match|
      friends_by_id_for_match = friends_by_id.slice(*match.group_member_ids).
        sort_by { |id, _friend| ids_in_order.index(id) }.to_h
      match.group_members = friends_by_id_for_match.values
    end
  end

  def group_members
    @group_members ||= user.friends.where(id: group_member_ids).order_by_name
  end

  def rank_tier
    return unless rank.present?
    self.class.rank_tier(rank)
  end

  def friend_count
    group_member_ids.size
  end

  def group_size
    friend_count + 1
  end

  def group_member_names
    group_members.map(&:name)
  end

  def hero_names
    heroes.map(&:name)
  end

  def placement_char
    char_for_boolean(placement)
  end

  def ally_thrower_char
    char_for_boolean(ally_thrower)
  end

  def ally_leaver_char
    char_for_boolean(ally_leaver)
  end

  def enemy_thrower_char
    char_for_boolean(enemy_thrower)
  end

  def enemy_leaver_char
    char_for_boolean(enemy_leaver)
  end

  def thrower?
    enemy_thrower? || ally_thrower?
  end

  def leaver?
    enemy_leaver? || ally_leaver?
  end

  def self.emoji_for_day_of_week(day_of_week)
    if day_of_week == :weekday
      "👔"
    elsif day_of_week == :weekend
      "🎉"
    end
  end

  def self.emoji_for_time_of_day(time_of_day)
    if time_of_day == :morning
      "🌅"
    elsif time_of_day == :evening
      "🌆"
    elsif time_of_day == :afternoon
      "😎"
    elsif time_of_day == :night
      "🌝"
    end
  end

  def self.day_time_summary(day_of_week, time_of_day)
    values = [day_of_week, time_of_day]
    emojis = [emoji_for_day_of_week(values[0]), emoji_for_time_of_day(values[1])]
    suffixes = values.map { |sym| sym.to_s.humanize }
    [emojis.join(' '), suffixes.join(' ')]
  end

  def day_time_summary
    self.class.day_time_summary(day_of_week, time_of_day)
  end

  def last_placement?
    return false unless placement?

    # Use this method to check before creating the last placement match, not
    # to check after the fact.
    return false if persisted?

    other_placements = account.matches.placements.in_season(season)
    other_placements.count == TOTAL_PLACEMENT_MATCHES - 1
  end

  # Public: Look up the prior match for a given match. Uses the hash of matches by ID
  # to avoid doing extra SQL queries.
  #
  # match - Match instance
  # matches_by_id - Hash of Match instances by their ID
  #
  # Returns a Match or nil.
  def self.prior_match_for(match, matches_by_id)
    if match.prior_match_id
      if matches_by_id.key?(match.prior_match_id)
        matches_by_id[match.prior_match_id]
      else
        match.prior_match
      end
    end
  end

  def self.get_win_streak(match, matches_by_id)
    return unless match.win?

    count = 1
    while (prior_match = prior_match_for(match, matches_by_id)) && prior_match.win?
      count += 1
      match = prior_match
    end
    count
  end

  def self.get_loss_streak(match, matches_by_id)
    return unless match.loss?

    count = 1
    while (prior_match = prior_match_for(match, matches_by_id)) && prior_match.loss?
      count += 1
      match = prior_match
    end
    count
  end

  def set_friends_from_names(names)
    friends_by_name = user.friends.where(name: names).
      map { |friend| [friend.name, friend] }.to_h
    friend_ids_to_keep = friends_by_name.values.map(&:id)
    self.group_member_ids = friend_ids_to_keep

    new_names = names - friends_by_name.keys
    new_names.each do |name|
      friend = friends_by_name[name] || user.friends.create(name: name)
      if friend.persisted?
        group_member_ids << friend.id
      end
    end
  end

  def placement_log?
    map.blank? && persisted? && !placement? && prior_match.nil?
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

  def night?
    time_of_day == :night
  end

  def morning?
    time_of_day == :morning
  end

  def evening?
    time_of_day == :evening
  end

  def afternoon?
    time_of_day == :afternoon
  end

  def day_of_week
    DAY_OF_WEEK_MAPPINGS.key(self[:day_of_week])
  end

  def day_of_week=(name)
    self[:day_of_week] = if name
      DAY_OF_WEEK_MAPPINGS[name.to_sym]
    end
  end

  def next_match
    return unless id && account && season
    account.matches.in_season(season).where(prior_match_id: id).first
  end

  private

  def reset_career_high
    return unless rank && account

    career_high = account.career_high
    if career_high && rank > career_high
      account.delete_career_high_cache
    end
  end

  def char_for_boolean(flag)
    unless flag.nil?
      flag ? 'Y' : 'N'
    end
  end

  def set_result
    return unless prior_match && rank && prior_match.rank

    self.result = if prior_match.rank < rank
      :win
    elsif prior_match.rank == rank
      :draw
    else
      :loss
    end
  end

  def rank_or_placement
    return if rank || placement?

    errors.add(:rank, 'is required if not a placement match')
  end

  def season_same_as_prior_match
    return unless season && prior_match

    unless prior_match.season == season
      errors.add(:season, 'must be the same as season from prior match')
    end
  end

  def account_has_not_met_season_limit
    return unless account && season

    other_matches = account.matches.in_season(season)
    other_matches = other_matches.where('id <> ?', id) if persisted?

    if other_matches.count >= MAX_PER_SEASON
      errors.add(:base, "#{account} has reached the maximum allowed number of matches in " \
                        "season #{season}.")
    end
  end

  def friend_user_matches_account
    return unless account && group_member_ids.present?
    friend_user_ids = Friend.where(id: group_member_ids).pluck(:user_id).uniq

    unless friend_user_ids.size == 1 && friend_user_ids.first == account.user_id
      errors.add(:group_member_ids, "has a group member who is not #{user}'s friend")
    end
  end

  def group_size_within_limit
    if friend_count > MAX_FRIENDS_PER_MATCH
      party = group_member_names.take(MAX_FRIENDS_PER_MATCH).join(', ')
      errors.add(:base, "Match already has a full group: you, #{party}")
    end
  end

  def delete_straggler_friends_on_save
    old_friend_ids = attribute_before_last_save('group_member_ids')
    removed_friend_ids = old_friend_ids - group_member_ids
    removed_friends = Friend.where(id: removed_friend_ids)
    removed_friends.each do |friend|
      friend.destroy if friend.matches.empty?
    end
  end

  def delete_straggler_friends_on_destroy
    old_friends = Friend.where(id: group_member_ids)
    old_friends.each do |friend|
      friend.destroy if friend.matches.empty?
    end
  end

  def hero_ids_exist
    return if hero_ids.empty?
    valid_hero_ids = Hero.pluck(:id)
    invalid_hero_ids = hero_ids - valid_hero_ids
    if invalid_hero_ids.any?
      errors.add(:hero_ids, "contains invalid values: #{invalid_hero_ids.map(&:to_s).join(', ')}")
    end
  end

  def update_next_match_prior_match
    return unless prior_match_id

    match_after = next_match
    return unless match_after

    match_after.prior_match_id = prior_match_id
    match_after.save
  end
end
