class Hero < ApplicationRecord
  ROLES = %w[healer DPS tank off-tank flanker defense hitscan].freeze

  validates :name, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: ROLES }

  has_and_belongs_to_many :matches

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
