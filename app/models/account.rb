class Account < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:bnet]

  VALID_PLATFORMS = {
    'pc' => 'PC',
    'psn' => 'PlayStation',
    'xbl' => 'Xbox'
  }.freeze

  VALID_REGIONS = {
    'us' => 'United States',
    'eu' => 'Europe',
    'kr' => 'South Korea',
    'cn' => 'China',
    'global' => 'Global'
  }.freeze

  URL_REGEX = %r{\Ahttps?://}.freeze

  belongs_to :user, required: false

  validates :battletag, presence: true
  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: [:provider, :battletag] }
  validates :platform, inclusion: { in: VALID_PLATFORMS.keys }, allow_nil: true
  validates :region, inclusion: { in: VALID_REGIONS.keys }, allow_nil: true
  validates :avatar_url, :level_url, format: URL_REGEX, allow_nil: true, allow_blank: true
  validates :rank, numericality: {
    only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: Match::MAX_RANK
  }, allow_nil: true
  validates :level, numericality: { only_integer: true, greater_than_or_equal_to: 1 },
    allow_nil: true

  scope :order_by_battletag, ->{ order('LOWER(battletag) ASC') }
  scope :without_user, ->{ where(user_id: nil) }
  scope :with_rank, ->{ where('rank IS NOT NULL') }
  scope :latest_first, ->{ order(updated_at: :desc) }
  scope :not_recently_updated, ->{ where('accounts.updated_at <= ?', 2.months.ago) }
  scope :without_avatar, ->{ where('avatar_url IS NULL') }
  scope :with_avatar, ->{ where('avatar_url IS NOT NULL') }

  scope :with_matches, -> do
    account_ids_with_matches = Match.group(:account_id).pluck(:account_id)
    where(id: account_ids_with_matches)
  end

  scope :without_matches, -> do
    account_ids_with_matches = Match.group(:account_id).pluck(:account_id)
    batch_size = 100
    scope = where(nil)
    account_ids_with_matches.each_slice(batch_size) do |account_ids|
      scope = scope.where('accounts.id NOT IN (?)', account_ids)
    end
    scope
  end

  scope :search_by_battletag, ->(query) do
    sanitized_query = query.gsub(/[\\_%]/) { |x| ["\\", x].join }
    where('LOWER(battletag) LIKE ?', "#{sanitized_query.downcase}%")
  end

  scope :sole_accounts, -> do
    joins(:user).joins('LEFT OUTER JOIN accounts other_accounts ' \
                       'ON users.id=other_accounts.user_id ' \
                       'AND other_accounts.id <> accounts.id').
      where('other_accounts.id IS NULL')
  end

  scope :near_season_match_limit, ->(season) do
    cutoff = Match::MAX_PER_SEASON - (Match::MAX_PER_SEASON * 0.15)
    matches = Match.in_season(season).group(:account_id).select(:account_id).
      having("COUNT(*) >= #{cutoff}")
    where(id: matches.map(&:account_id))
  end

  after_update :refresh_profile_data, if: :saved_change_to_platform?

  alias_attribute :to_s, :battletag

  has_many :matches, dependent: :restrict_with_exception
  has_many :season_shares, dependent: :destroy

  def self.find_by_param(battletag_param)
    battletag = battletag_param.split('-').join('#')
    where(battletag: battletag).first
  end

  def self.find_by_name(name)
    sanitized_query = name.gsub(/[\\_%]/) { |x| ["\\", x].join } + '%'
    where('battletag LIKE ?', sanitized_query).first
  end

  def self.top_rank
    with_rank.select('MAX(rank) AS max_rank').to_a.first.max_rank
  end

  def self.bottom_rank
    with_rank.select('MIN(rank) AS min_rank').to_a.first.min_rank
  end

  def self.average_rank
    avg_rank = with_rank.select('AVG(rank) AS avg_rank').to_a.first.avg_rank
    return unless avg_rank
    avg_rank.round
  end

  def most_played_heroes(limit: 5)
    matches_played_by_hero_id = Match.count_by_hero_id(scope: Match.where(account_id: id))
    hero_ids = matches_played_by_hero_id.keys.take(limit)
    heroes_by_id = Hero.where(id: hero_ids).map { |hero| [hero.id, hero] }.to_h
    hero_ids.map do |hero_id|
      hero = heroes_by_id[hero_id]
      [hero, matches_played_by_hero_id[hero_id]]
    end.to_h
  end

  # Public: Check if this account hasn't been updated in a while.
  def out_of_date?
    time_diff = Time.zone.now - updated_at
    time_diff >= 2.weeks
  end

  def name
    battletag.split('#').first
  end

  def overwatch_api_profile
    data = Rails.cache.fetch(overwatch_api_profile_cache_key, expires_in: 2.weeks) do
      overwatch_api.profile
    end
    return unless data

    OverwatchAPIProfile.new(data, region: region)
  end

  def overbuff_url
    "https://www.overbuff.com/players/#{platform}/#{to_param}?mode=competitive"
  end

  def master_overwatch_url
    "https://masteroverwatch.com/profile/#{platform}/#{region}/#{to_param}"
  end

  def play_overwatch_url
    "https://playoverwatch.com/en-us/career/#{platform}/#{to_param}"
  end

  def delete_career_high_cache
    Rails.cache.delete(career_high_cache_key)
  end

  def season_high(season)
    highest_sr_match = matches.in_season(season).with_rank.order('rank DESC').first
    highest_sr_match.try(:rank)
  end

  def career_high
    cache_key = career_high_cache_key
    existing_career_high = Rails.cache.fetch(cache_key)
    return existing_career_high if existing_career_high

    return unless persisted? && matches.any?

    highest_sr_match = matches.where('season <> ?', 1).with_rank.order('rank DESC').first
    new_career_high = highest_sr_match.try(:rank)

    Rails.cache.write(cache_key, new_career_high) if new_career_high

    new_career_high
  end

  def season_is_public?(season)
    season_number = season.is_a?(Season) ? season.number : season
    season_shares.exists?(season: season_number)
  end

  def can_be_unlinked?
    user && user.accounts.count > 1
  end

  def active_seasons
    matches.select('DISTINCT season').order(:season).map(&:season)
  end

  def wipe_season(season)
    matches.in_season(season).destroy_all
  end

  def import(season, path:)
    importer = MatchImporter.new(account: self, season: season)
    importer.import(path)
    importer.matches
  end

  def export(season)
    exporter = MatchExporter.new(account: self, season: season)
    exporter.export
  end

  def last_placement_match_in(season)
    matches.in_season(season).placements.with_rank.ordered_by_time.last
  end

  def finished_placements?(season)
    return @finished_placements if defined? @finished_placements
    season_placement_count = matches.placements.in_season(season).count
    @finished_placements = if season_placement_count >= Match::TOTAL_PLACEMENT_MATCHES
      true
    else
      matches.non_placements.in_season(season).any? &&
        matches.in_season(season).placement_logs.any?
    end
  end

  def any_placements?(season)
    matches.placements.in_season(season).any?
  end

  def to_param
    return unless battletag
    User.parameterize(battletag)
  end

  def platform_name
    VALID_PLATFORMS[platform]
  end

  def region_name
    VALID_REGIONS[region]
  end

  def api_response
    overwatch_api.response
  end

  private

  def overwatch_api
    @overwatch_api ||= OverwatchAPI.new(battletag: battletag, platform: platform)
  end

  def overwatch_api_profile_cache_key
    "owapi/profile/#{battletag}/#{platform}"
  end

  def career_high_cache_key
    "career-high-#{battletag}"
  end

  def refresh_profile_data
    SetProfileDataJob.perform_later(id)
  end
end
