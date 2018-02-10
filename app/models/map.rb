class Map < ApplicationRecord
  extend FriendlyId

  VALID_MAP_TYPES = %w[assault escort hybrid control].freeze

  validates :name, presence: true, uniqueness: true
  validates :map_type, presence: true, inclusion: { in: VALID_MAP_TYPES }

  has_many :matches

  friendly_id :name, use: :slugged

  alias_attribute :to_s, :name

  def image_name
    @image_name ||= "#{slug}.png"
  end
end
