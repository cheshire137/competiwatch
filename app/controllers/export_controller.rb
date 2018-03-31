class ExportController < ApplicationController
  before_action :authenticate_account!
  before_action :set_account, only: :export
  before_action :ensure_account_is_mine, only: :export
  before_action :set_season, only: :export

  def index
    @accounts = current_user.accounts.order_by_battletag
    @seasons = (1..Season.latest_number).to_a.reverse
    @match_counts = current_user.matches.group(:account_id, :season).count
  end

  def export
    date = Time.now.strftime('%Y-%m-%d')
    filename = "#{@account.to_param}-season-#{@season}-#{date}.csv"

    respond_to do |format|
      format.csv do
        send_data @account.export(@season), filename: filename
      end
    end
  end
end
