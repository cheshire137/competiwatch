class Map < ApplicationRecord
  extend FriendlyId

  VALID_MAP_TYPES = %w[assault escort hybrid control].freeze

  scope :order_by_name, ->{ order(:name) }

  validates :name, presence: true, uniqueness: true
  validates :map_type, presence: true, inclusion: { in: VALID_MAP_TYPES }

  has_many :matches

  friendly_id :name, use: :slugged

  alias_attribute :to_s, :name

  def image_name
    @image_name ||= "#{slug}.png"
  end

  def chart_label
    return 'WP: Gibraltar' if name == 'Watchpoint: Gibraltar'
    return 'Volskaya' if name == 'Volskaya Industries'
    return 'B. World' if name == 'Blizzard World'
    return 'H. Lunar Colony' if name == 'Horizon Lunar Colony'
    return 'Anubis' if name == 'Temple of Anubis'
    name
  end
end
