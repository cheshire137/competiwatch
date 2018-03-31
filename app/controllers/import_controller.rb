class ImportController < ApplicationController
  before_action :authenticate_account!
  before_action :set_account
  before_action :ensure_account_is_mine
  before_action :set_season

  def index
    @matches = nil
    @match_count = @account.matches.in_season(@season_number).count
  end

  def create
    file = params[:csv]
    unless file
      flash[:alert] = 'No CSV file was provided.'
      return redirect_to(import_path(@season_number, @account))
    end

    @matches = @account.import(@season_number, path: file.path)

    results = @matches.map(&:persisted?)
    @match_count = @account.matches.in_season(@season_number).count

    if @matches.empty?
      flash[:alert] = 'No matches were found in the selected file.'
      render 'import/index'
    elsif results.all?
      flash[:notice] = "Successfully imported #{@matches.size} " +
        "#{'match'.pluralize(@matches.size)} to #{@account} season #{@season}."
      redirect_to matches_path(@season_number, @account)
    elsif results.any?
      success_count = @matches.select(&:persisted?).size
      failure_count = @matches.select(&:new_record?).size
      flash[:alert] = "Imported #{success_count} #{'match'.pluralize(success_count)}, but " \
        "#{failure_count} #{'match'.pluralize(failure_count)} failed to import to " \
        "#{@account} season #{@season}."
      render 'import/index'
    else
      flash[:error] = "Failed to import #{@matches.size} #{'match'.pluralize(@matches.size)} to " \
                      "#{@account} season #{@season}."
      render 'import/index'
    end
  end
end
