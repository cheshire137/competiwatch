class User < ApplicationRecord
  has_many :accounts, dependent: :restrict_with_exception
  has_many :friends, dependent: :destroy
  has_many :matches, through: :accounts
  has_many :season_shares, through: :accounts

  validates :battletag, presence: true, uniqueness: true

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

  # Public: See how many users there are with the specified number of linked accounts.
  def self.total_by_account_count(num_accounts:)
    num_accounts = num_accounts.to_i
    query = <<-SQL
      SELECT COUNT(*) FROM (
        SELECT user_id, COUNT(*) FROM accounts GROUP BY user_id
      ) accounts_by_user WHERE count = #{num_accounts}
    SQL
    result = ActiveRecord::Base.connection.exec_query(query)
    row = result.rows.first
    row.first
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
        Match.with_group_member(secondary_friend).each do |match|
          match.group_member_ids -= [secondary_friend.id]
          match.group_member_ids << primary_friend.id
          success = success && match.save
          break unless success
        end
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
    Match.prefill_group_members(season_matches, user: self)
    season_matches.flat_map(&:group_members).uniq.
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
end
