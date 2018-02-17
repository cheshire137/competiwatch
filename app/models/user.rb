class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:bnet]

  has_many :oauth_accounts, dependent: :destroy
  has_many :friends, dependent: :destroy
  has_many :matches, through: :oauth_accounts

  belongs_to :default_oauth_account, class_name: 'OauthAccount', required: false

  validates :battletag, presence: true, uniqueness: true
  validate :default_oauth_account_is_owned

  alias_attribute :to_s, :battletag

  scope :order_by_battletag, ->{ order("LOWER(battletag)") }

  def merge_with(primary_user)
    success = true

    oauth_accounts.each do |oauth_account|
      oauth_account.user = primary_user
      success = success && oauth_account.save
    end

    friends.each do |secondary_friend|
      primary_friend = primary_user.friends.find_by_name(secondary_friend.name)
      if primary_friend
        MatchFriend.where(friend_id: secondary_friend.id).update_all(friend_id: primary_friend.id)
        success = success && secondary_friend.destroy
      else
        secondary_friend.user = primary_user
        success = success && secondary_friend.save
      end
    end

    # Need to refresh the lists so #destroy doesn't delete them
    oauth_accounts.reload
    friends.reload

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

  def default_oauth_account_is_owned
    return unless default_oauth_account

    unless oauth_accounts.include?(default_oauth_account)
      errors.add(:default_oauth_account, 'must be one of your accounts')
    end
  end
end
