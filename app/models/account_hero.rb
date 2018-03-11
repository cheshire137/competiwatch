class AccountHero < ApplicationRecord
  MAX_HEROES_PER_ACCOUNT = 5

  belongs_to :account
  belongs_to :hero

  validates :seconds_played, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
    allow_nil: true
  validate :within_limit_per_account

  scope :ordered_by_playtime, ->{ order(seconds_played: :desc) }

  def playtime
    return unless seconds_played && seconds_played > 0

    secs = seconds_played
    [[60, 'second'], [60, 'minute'], [24, 'hour'], [1000, 'day']].map do |count, name|
      secs, n = secs.divmod(count)
      "#{n.to_i} #{name.pluralize(n.to_i)}" if n > 0
    end.compact.reverse.join(' ')
  end

  private

  def within_limit_per_account
    return unless account

    existing_account_heroes = account.account_heroes
    existing_account_heroes = existing_account_heroes.where('id <> ?', id) if persisted?

    if existing_account_heroes.count >= MAX_HEROES_PER_ACCOUNT
      errors.add(:account, 'already has as many top heroes as is allowed per account')
    end
  end
end
