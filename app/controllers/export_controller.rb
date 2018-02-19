class ExportController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account, only: :export
  before_action :ensure_oauth_account_is_mine, only: :export
  before_action :set_season, only: :export

  def index
  end

  def export
    date = Time.now.strftime('%Y-%m-%d')
    filename = "#{@oauth_account.to_param}-season-#{@season}-#{date}.csv"

    respond_to do |format|
      format.csv do
        send_data @oauth_account.export(@season), filename: filename
      end
    end
  end
end
