class LoginController < ApplicationController
  before_action :redirect_if_signed_in

  def index
  end

  private

  def redirect_if_signed_in
    if signed_in?
      season = Season.current_or_latest_number
      redirect_to matches_path(season, current_account)
    end
  end
end
