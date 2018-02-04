class Hero < ApplicationRecord
  ROLES = %w[healer DPS tank off-tank flanker defense hitscan].freeze

  validates :name, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: ROLES }
end
