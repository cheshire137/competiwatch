class Hero < ApplicationRecord
  ROLES = %w[healer DPS tank off-tank flanker defense hitscan].freeze

  validates :name, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: ROLES }

  scope :order_by_name, ->{ order('LOWER(name) ASC') }

  alias_attribute :to_s, :name

  has_and_belongs_to_many :matches

  ALIASES = {
    widow: 'Widowmaker',
    torb: 'Torbjörn',
    soldier: 'Soldier: 76',
    sym: 'Symmetra',
    symm: 'Symmetra',
    df: 'Doomfist',
    rein: 'Reinhardt',
    zen: 'Zenyatta',
    hog: 'Roadhog',
    cree: 'McCree',
    junk: 'Junkrat',
    rat: 'Junkrat'
  }

  def self.full_name_from_alias(hero_alias)
    ALIASES[hero_alias.downcase.to_sym] || hero_alias
  end

  def self.slug_for(name)
    case name
    when 'D.Va' then 'dva'
    when 'Lúcio' then 'lucio'
    when 'Soldier: 76' then 'soldier76'
    when 'Torbjörn' then 'torbjorn'
    else name.downcase
    end
  end

  # "Lúcio" => "lucio"
  # "Widow" => "widowmaker"
  # "dva" => "dva"
  # "D.Va" => "dva"
  # "Torb" => "torbjorn"
  def self.flatten_name(name)
    full_name = full_name_from_alias(name)
    flattened_name = full_name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'')
    slug_for(flattened_name).to_s
  end

  def slug
    @slug ||= self.class.slug_for(name)
  end
end
