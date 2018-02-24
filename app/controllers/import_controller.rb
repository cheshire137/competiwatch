class ImportController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account
  before_action :ensure_oauth_account_is_mine
  before_action :set_season

  def index
    @matches = nil
    @match_count = @oauth_account.matches.in_season(@season_number).count
  end

  def create
    file = params[:csv]
    unless file
      flash[:alert] = 'No CSV file was provided.'
      return redirect_to(import_path(@season_number, @oauth_account))
    end

    @matches = @oauth_account.import(@season_number, path: file.path)

    results = @matches.map(&:persisted?)
    @match_count = @oauth_account.matches.in_season(@season_number).count

    if @matches.empty?
      flash[:alert] = 'No matches were found in the selected file.'
      render 'import/index'
    elsif results.all?
      flash[:notice] = "Successfully imported #{@matches.size} " +
        "#{'match'.pluralize(@matches.size)} to #{@oauth_account} season #{@season}."
      redirect_to matches_path(@season_number, @oauth_account)
    elsif results.any?
      success_count = @matches.select(&:persisted?).size
      failure_count = @matches.select(&:new_record?).size
      flash[:alert] = "Imported #{success_count} #{'match'.pluralize(success_count)}, but " \
        "#{failure_count} #{'match'.pluralize(failure_count)} failed to import to " \
        "#{@oauth_account} season #{@season}."
      render 'import/index'
    else
      flash[:error] = "Failed to import #{@matches.size} #{'match'.pluralize(@matches.size)} to " \
                      "#{@oauth_account} season #{@season}."
      render 'import/index'
    end
  end
end
