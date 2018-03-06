class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:bnet]

  has_many :oauth_accounts, dependent: :destroy
  has_many :friends, dependent: :destroy
  has_many :matches, through: :oauth_accounts
  has_many :season_shares, through: :oauth_accounts

  belongs_to :default_oauth_account, class_name: 'OAuthAccount', required: false

  validates :battletag, presence: true, uniqueness: true
  validate :default_oauth_account_is_owned

  alias_attribute :to_s, :battletag

  scope :order_by_battletag, ->{ order("LOWER(battletag)") }
  scope :active, -> do
    cutoff_time = Time.zone.now - 1.month
    account_user_ids = OAuthAccount.where('updated_at >= ?', cutoff_time).pluck(:user_id)
    share_user_ids = SeasonShare.joins(:oauth_account).
      where('season_shares.created_at >= ?', cutoff_time).pluck('oauth_accounts.user_id')
    match_user_ids = Match.joins(:oauth_account).where('matches.updated_at >= ?', cutoff_time).
      pluck('oauth_accounts.user_id')
    where(id: account_user_ids | share_user_ids | match_user_ids)
  end

  def season_high(season)
    highest_sr_match = matches.in_season(season).with_rank.order('rank DESC').first
    highest_sr_match.try(:rank)
  end

  def career_high
    oauth_accounts.map(&:career_high).compact.max
  end

  def active_seasons
    matches.select('DISTINCT season').order('season').map(&:season)
  end

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
    matches.in_season(season).includes(:friends).flat_map(&:friends).uniq.
      sort_by { |friend| friend.name.downcase }.map(&:name)
  end

  def all_friend_names
    friends.order_by_name.pluck(:name)
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
