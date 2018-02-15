class SeasonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account

  def index
  end
end
