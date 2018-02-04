class OauthAccount < ApplicationRecord
  belongs_to :user

  validates :battletag, presence: true
  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }

  alias_attribute :to_s, :battletag

  has_many :matches

  def self.find_by_battletag(battletag)
    where("LOWER(battletag) = ?", battletag.downcase).first
  end

  def finished_placements?(season)
    if matches.placements.in_season(season).count == Match::TOTAL_PLACEMENT_MATCHES
      return true
    end

    matches.non_placements.in_season(season).any? &&
      matches.in_season(season).placement_logs.any?
  end

  def to_param
    User.parameterize(battletag)
  end
end
