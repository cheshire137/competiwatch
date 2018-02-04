class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:bnet]

  validates :battletag, uniqueness: true

  alias_attribute :to_s, :battletag

  scope :order_by_battletag, ->{ order("LOWER(battletag)") }

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
