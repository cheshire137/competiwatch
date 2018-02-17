class OauthAccount < ApplicationRecord
  belongs_to :user, required: false

  validates :battletag, presence: true
  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }

  scope :order_by_battletag, ->{ order('LOWER(battletag) ASC') }

  after_update :remove_default, if: :saved_change_to_user_id?

  alias_attribute :to_s, :battletag

  has_many :matches, dependent: :destroy
  has_many :heroes, through: :matches
  has_many :season_shares, dependent: :destroy

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
end
