class MatchesController < ApplicationController
  before_action :authenticate_user!

  def index
    @maps = get_maps
    @heroes = get_heroes
    @oauth_account = current_user.oauth_accounts.first
    all_matches = @oauth_account.matches.order(:time)
    latest_match = all_matches.last
    @matches = if latest_match
      all_matches.in_season(latest_match.season)
    else
      []
    end
    @current_season = latest_match.try(:season) || 8
    @match = Match.new(oauth_account: @oauth_account, time: Time.zone.now,
                       prior_match: latest_match, season: @current_season)
  end

  private

  def get_maps
    Rails.cache.fetch('maps') { Map.order(:name).select([:id, :name]) }
  end

  def get_heroes
    Rails.cache.fetch('heroes') { Hero.order(:name) }
  end
end
