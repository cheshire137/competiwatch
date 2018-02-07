class ImportController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account
  before_action :set_season

  def index
    @match_count = @oauth_account.matches.in_season(@season).count
  end

  def create
  end
end
