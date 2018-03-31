class Friend < ApplicationRecord
  MAX_NAME_LENGTH = 30

  belongs_to :account

  validates :name, presence: true, uniqueness: { scope: :account_id },
    length: { maximum: MAX_NAME_LENGTH }

  scope :order_by_name, ->{ order('LOWER(name) ASC') }

  after_destroy :remove_from_matches

  def matches
    Match.joins(:account).where(account_id: account_id).with_group_member(self)
  end

  private

  def remove_from_matches
    matches.each do |match|
      match.group_member_ids -= [id]
      match.save
    end
  end
end
