class Map < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :map_type, presence: true

  has_many :matches
end