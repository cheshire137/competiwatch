class Hero < ApplicationRecord
  ROLES = %w[healer DPS tank off-tank flanker defense hitscan].freeze

  validates :name, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: ROLES }

  has_and_belongs_to_many :matches

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
  def self.flatten_name(name)
    slug_for(name).mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s
  end

  def slug
    @slug ||= self.class.slug_for(name)
  end
end
