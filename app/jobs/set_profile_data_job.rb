class SetProfileDataJob < ApplicationJob
  queue_as :default

  def perform(*args)
    account_id = args.first
    return unless account_id

    account = Account.find_by_id(account_id)
    return unless account

    profile = account.overwatch_api_profile
    return unless profile

    account.avatar_url = profile.avatar_url

    if account.changed? && !account.save
      errors = account.errors.full_messages.join(', ')
      Rails.logger.error('SetProfileDataJob failed to update account ' \
                         "#{account}:\n\t#{errors}")
    end
  end
end
