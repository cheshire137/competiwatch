class LoginController < ApplicationController
  before_action :redirect_if_signed_in

  def index
  end

  private

  def redirect_if_signed_in
    account = current_user.oauth_accounts.first
    redirect_to(matches_path(account)) if signed_in?
  end
end
