class Hero < ApplicationRecord
  ROLES = %w[healer DPS tank off-tank flanker defense hitscan].freeze

  validates :name, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: ROLES }

  has_and_belongs_to_many :matches

  # "Lúcio" => "lucio"
  def self.flatten_name(name)
    name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s
  end

  def slug
    @slug ||= case name
      when 'D.Va' then 'dva'
      when 'Lúcio' then 'lucio'
      when 'Soldier: 76' then 'soldier76'
      when 'Torbjörn' then 'torbjorn'
      else name.downcase
      end
  end
end
