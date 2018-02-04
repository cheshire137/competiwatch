class LoginController < ApplicationController
  before_action :redirect_if_signed_in

  def index
  end

  private

  def redirect_if_signed_in
    redirect_to(matches_path(Match::LATEST_SEASON, current_user.primary_account)) if signed_in?
  end
end
