class UsersController < ApplicationController
  before_action :authenticate_user!

  def settings
  end

  def confirm_delete
    @match_count = current_user.matches.count
    @season_count = current_user.matches.group(:season).count.keys.size
    @account_count = current_user.accounts.count
    @accounts = current_user.accounts.order_by_battletag
    @match_count_by_account_id = current_user.matches.group(:account_id).count
  end

  def destroy
    accounts = current_user.accounts
    accounts.each do |account|
      account.season_shares.destroy_all
      account.matches.destroy_all
    end
    accounts.destroy_all
    current_user.friends.destroy_all
    user = current_user
    sign_out current_user
    user.destroy!
    redirect_to root_path, notice: "Competiwatch account deleted."
  end
end
