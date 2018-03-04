class OAuthAccount < ApplicationRecord
  belongs_to :user, required: false

  validates :battletag, presence: true
  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }

  scope :order_by_battletag, ->{ order('LOWER(battletag) ASC') }
  scope :without_user, ->{ where(user_id: nil) }

  after_update :remove_default, if: :saved_change_to_user_id?

  alias_attribute :to_s, :battletag

  has_many :matches, dependent: :destroy
  has_many :heroes, through: :matches
  has_many :season_shares, dependent: :destroy

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
    user && user.oauth_accounts.count > 1
  end

  def default?
    user && user.default_oauth_account == self
  end

  def active_seasons
    matches.select('DISTINCT season').order(:season).map(&:season)
  end

  def wipe_season(season)
    matches.in_season(season).destroy_all
  end

  def import(season, path:)
    importer = MatchImporter.new(oauth_account: self, season: season)
    importer.import(path)
    importer.matches
  end

  def export(season)
    exporter = MatchExporter.new(oauth_account: self, season: season)
    exporter.export
  end

  def last_placement_match_in(season)
    matches.in_season(season).placements.with_rank.ordered_by_time.last
  end

  def self.find_by_battletag(battletag)
    where("LOWER(battletag) = ?", battletag.downcase).first
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
    User.parameterize(battletag)
  end

  def remove_default
    return unless user_id_before_last_save

    user = User.where(id: user_id_before_last_save).first
    return unless user && user.default_oauth_account == self

    user.default_oauth_account = user.oauth_accounts.first
    user.save
  end

  private

  def career_high_cache_key
    "career-high-#{battletag}"
  end
end
