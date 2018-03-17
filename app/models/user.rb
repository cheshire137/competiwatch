class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:bnet]

  has_many :accounts, dependent: :destroy
  has_many :friends, dependent: :destroy
  has_many :matches, through: :accounts
  has_many :season_shares, through: :accounts

  belongs_to :default_account, class_name: 'Account', required: false

  validates :battletag, presence: true, uniqueness: true
  validate :default_account_is_owned

  alias_attribute :to_s, :battletag

  scope :order_by_battletag, ->{ order("LOWER(battletag)") }
  scope :active, -> do
    cutoff_time = Time.zone.now - 1.month
    share_user_ids = SeasonShare.joins(:account).
      where('season_shares.created_at >= ?', cutoff_time).pluck('accounts.user_id')
    match_user_ids = Match.joins(:account).where('matches.updated_at >= ?', cutoff_time).
      pluck('accounts.user_id')
    where(id: share_user_ids | match_user_ids)
  end

  def name
    battletag.split('#').first
  end

  def season_high(season)
    highest_sr_match = matches.in_season(season).with_rank.order('rank DESC').first
    highest_sr_match.try(:rank)
  end

  def career_high
    accounts.map(&:career_high).compact.max
  end

  def active_seasons
    matches.select('DISTINCT season').order('season').map(&:season)
  end

  def merge_with(primary_user)
    success = true

    accounts.each do |account|
      account.user = primary_user
      success = success && account.save
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
    accounts.reload
    friends.reload

    success && destroy
  end

  def friend_names(season)
    season_matches = matches.in_season(season)
    Match.prefill_friends(season_matches, user: self)
    season_matches.flat_map(&:friends).uniq.
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

  def default_account_is_owned
    return unless default_account

    unless accounts.include?(default_account)
      errors.add(:default_account, 'must be one of your accounts')
    end
  end
end
