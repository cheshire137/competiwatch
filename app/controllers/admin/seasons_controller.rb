class Admin::SeasonsController < ApplicationController
  before_action :require_admin

  def index
    @new_season = Season.new(number: Season.current_or_latest_number + 1)
    @seasons = Season.latest_first
  end

  def destroy
    season = Season.find(params[:season_id])

    if season.destroy
      flash[:notice] = "Successfully deleted season #{season}."
    else
      flash[:error] = "Could not delete season #{season}: " + season.errors.full_messages.join(', ')
    end

    redirect_to admin_path
  end

  def create
    season = Season.new
    season.assign_attributes(new_season_params)

    if season.save
      flash[:notice] = "Successfully created season #{season}."
    else
      flash[:error] = "Could not create season #{season}: " + season.errors.full_messages.join(', ')
    end

    redirect_to admin_path
  end

  def update
    season = Season.find(params[:season_id])
    season.assign_attributes(season_params)

    if season.save
      flash[:notice] = "Successfully updated season #{season}."
    else
      flash[:error] = "Could not update season #{season}: " + season.errors.full_messages.join(', ')
    end

    redirect_to admin_path
  end

  private

  def new_season_params
    params.require(:create_season).permit([:started_on, :ended_on, :max_rank, :number])
  end

  def season_params
    params.require(:update_season).permit([:started_on, :ended_on, :max_rank])
  end
end
