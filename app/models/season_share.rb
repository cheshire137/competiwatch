class SeasonShare < ApplicationRecord
  belongs_to :account

  validates :season, presence: true, uniqueness: { scope: :account_id }

  scope :in_season, ->(season) {
    if season.is_a?(Season)
      where(season: season.number)
    else
      where(season: season)
    end
  }
  scope :with_matches, ->(season) do
    match_sub_query = Match.in_season(season).group(:account_id).select(:account_id)
    in_season(season).where(account_id: match_sub_query)
  end
  scope :random_order, ->{ order('random()') }
end
