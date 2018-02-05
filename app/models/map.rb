class Map < ApplicationRecord
  extend FriendlyId

  validates :name, presence: true, uniqueness: true
  validates :map_type, presence: true

  has_many :matches

  friendly_id :name, use: :slugged

  alias_attribute :to_s, :name

  def image_name
    @image_name ||= "#{slug}.png"
  end
end
