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

  def to_param
    User.parameterize(battletag)
  end
end
