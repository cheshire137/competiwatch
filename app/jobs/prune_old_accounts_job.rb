class PruneOldAccountsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    accounts = Account.without_matches.sole_accounts.not_recently_updated.includes(:user)
    if accounts.count < 1
      Rails.logger.info 'PruneOldAccountsJob no old single accounts without matches'
      return
    end

    Rails.logger.info "PruneOldAccountsJob deleting #{accounts.count} account(s) and their users"
    users = accounts.map(&:user)
    accounts.destroy_all
    users.map(&:destroy)
  end
end
