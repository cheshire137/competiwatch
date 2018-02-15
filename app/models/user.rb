class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:bnet]

  validates :battletag, presence: true, uniqueness: true

  has_many :oauth_accounts, dependent: :destroy
  has_many :friends, dependent: :destroy
  has_many :matches, through: :oauth_accounts

  alias_attribute :to_s, :battletag

  scope :order_by_battletag, ->{ order("LOWER(battletag)") }

  def merge_with(primary_user)
    success = true

    oauth_accounts.each do |oauth_account|
      oauth_account.user = primary_user
      success = success && oauth_account.save
    end

    friends.each do |friend|
      friend.user = primary_user
      success = success && friend.save
    end

    success && destroy
  end

  def friend_names(season)
    season_matches = matches.in_season(season).includes(:friends)
    if season_matches.empty?
      all_friend_names
    else
      season_matches.flat_map(&:friends).uniq.
        sort_by { |friend| friend.name.downcase }.map(&:name)
    end
  end

  def all_friend_names
    friends.order_by_name.pluck(:name)
  end

  def self.find_by_battletag(battletag)
    where("LOWER(battletag) = ?", battletag.downcase).first
  end

  def self.battletag_from_param(str)
    index = str.rindex('-')
    start = str[0...index]
    rest = str[index+1...str.size]
    "#{start}##{rest}"
  end

  def self.parameterize(battletag)
    battletag.split('#').join('-')
  end

  def to_param
    self.class.parameterize(battletag)
  end
end
