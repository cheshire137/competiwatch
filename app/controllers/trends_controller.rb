class TrendsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account
  before_action :set_season
  layout false

  def wins_by_map_chart
    maps_by_id = Map.order(:name).select([:id, :name, :color]).
      map { |map| [map.id, map] }.to_h
    wins_by_map_id = @oauth_account.matches.in_season(@season).wins.
      group(:map_id).count
    @map_names = maps_by_id.values.map(&:name)
    @win_counts = maps_by_id.keys.map do |map_id|
      wins_by_map_id[map_id] || 0
    end
    @colors = maps_by_id.values.map(&:color)
  end

  def win_loss_chart
    matches = @oauth_account.matches.in_season(@season).group(:result).count
    @win_count = matches[Match::RESULT_MAPPINGS[:win]]
    @loss_count = matches[Match::RESULT_MAPPINGS[:loss]]
    @draw_count = matches[Match::RESULT_MAPPINGS[:draw]]
  end
end
