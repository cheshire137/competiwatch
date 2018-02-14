class Friend < ApplicationRecord
  MAX_NAME_LENGTH = 30

  belongs_to :user
  has_many :match_friends
  has_many :matches, through: :match_friends

  validates :name, presence: true, uniqueness: { scope: :user_id },
    length: { maximum: MAX_NAME_LENGTH }

  scope :order_by_name, ->{ order('LOWER(name) ASC') }
end
