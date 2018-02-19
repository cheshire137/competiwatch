class ExportController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_account, only: :export
  before_action :ensure_oauth_account_is_mine, only: :export
  before_action :set_season, only: :export

  def index
    @oauth_accounts = current_user.oauth_accounts.order_by_battletag
    @seasons = (1..Match::LATEST_SEASON).to_a.reverse
    @match_counts = current_user.matches.group(:oauth_account_id, :season).count
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
