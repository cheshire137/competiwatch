class MatchesController < ApplicationController
  before_action :authenticate_user!

  def index
    @maps = get_maps
    @oauth_account = current_user.oauth_accounts.first
    all_matches = @oauth_account.matches.order(:time)
    latest_match = all_matches.last
    @matches = if latest_match
      all_matches.where(season: latest_match.season)
    end
    @match = Match.new(oauth_account: @oauth_account, time: Time.zone.now,
                       prior_match: latest_match)
  end

  private

  def get_maps
    Rails.cache.fetch('maps') { Map.order(:name).select([:id, :name]) }
  end
end
