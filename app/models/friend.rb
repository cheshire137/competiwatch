class Friend < ApplicationRecord
  MAX_NAME_LENGTH = 30
  MAX_FRIENDS_PER_MATCH = 5

  belongs_to :user

  validates :name, presence: true, uniqueness: { scope: :user_id },
    length: { maximum: MAX_NAME_LENGTH }

  scope :order_by_name, ->{ order('LOWER(name) ASC') }
end
