class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:bnet]

  validates :battletag, presence: true, uniqueness: true

  has_many :oauth_accounts, dependent: :destroy
  has_many :friends, class_name: 'MatchFriend', dependent: :destroy

  alias_attribute :to_s, :battletag

  scope :order_by_battletag, ->{ order("LOWER(battletag)") }

  def friend_names
    friends.order_by_name.group(:name).pluck(:name)
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

  def primary_account
    oauth_accounts.first
  end

  def to_param
    self.class.parameterize(battletag)
  end
end
