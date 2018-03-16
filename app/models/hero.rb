class Hero < ApplicationRecord
  ROLES = %w[healer DPS tank off-tank flanker defense hitscan].freeze

  validates :name, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: ROLES }

  scope :order_by_name, ->{ order(:name) }

  alias_attribute :to_s, :name

  has_and_belongs_to_many :matches

  ROLE_SORT = {
    'DPS' => 0,
    'hitscan' => 1,
    'flanker' => 2,
    'tank' => 3,
    'off-tank' => 4,
    'healer' => 5,
    'defense' => 6
  }.freeze

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

  def self.most_played(limit: 5)
    matches_played_by_hero_id = MatchHero.group(:hero_id).count.
      sort_by { |_hero_id, match_count| -match_count }.to_h
    hero_ids = matches_played_by_hero_id.keys.take(limit)
    heroes = Hero.where(id: hero_ids).map { |hero| [hero.id, hero] }.to_h
    hero_ids.map do |hero_id|
      hero = heroes[hero_id]
      [hero, matches_played_by_hero_id[hero_id]]
    end.to_h
  end

  def self.pretty_role(role)
    return role if role == 'DPS'
    role.humanize
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
