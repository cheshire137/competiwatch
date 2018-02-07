class ImportController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account
  before_action :set_season

  def index
    @matches = nil
    @match_count = @oauth_account.matches.in_season(@season).count
  end

  def create
    file = params[:csv]
    table = CSV.read(file.path, headers: true, header_converters: [:downcase])
    map_ids_by_name = Map.select([:id, :name]).map { |map| [map.name, map.id] }.to_h
    @matches = []

    # Wipe existing matches this season
    @oauth_account.matches.in_season(@season).destroy_all

    prior_match = nil
    table.each do |row|
      match = @oauth_account.matches.new(rank: row['rank'].to_i, season: @season,
                                         comment: row['comment'], prior_match: prior_match)
      if (map_name = match['map']).present?
        match.map_id = map_ids_by_name[map_name]
      end

      match.save
      prior_match = if match.persisted?
        match
      end
      @matches << match
    end

    results = @matches.map(&:persisted?)
    @match_count = @oauth_account.matches.in_season(@season).count

    if @matches.empty?
      flash[:alert] = 'No matches were found in the selected file.'
      render 'import/index'
    elsif results.all?
      flash[:notice] = "Successfully imported #{@matches.size} " +
        "#{'match'.pluralize(@matches.size)} to #{@season}."
      redirect_to matches_path(@season, @oauth_account)
    elsif results.any?
      success_count = @matches.select(&:persisted?).size
      failure_count = @matches.select(&:new_record?).size
      flash[:alert] = "Imported #{success_count} #{'match'.pluralize(success_count)}, but " +
        "#{failure_count} #{'match'.pluralize(failure_count)} failed to import."
      render 'import/index'
    else
      flash[:error] = "Failed to import #{@matches.size} #{'match'.pluralize(@matches.size)}."
      render 'import/index'
    end
  end
end
