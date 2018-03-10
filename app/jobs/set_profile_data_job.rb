class SetProfileDataJob < ApplicationJob
  queue_as :default

  def perform(*args)
    oauth_account_id = args.first
    return unless oauth_account_id

    oauth_account = OAuthAccount.find_by_id(oauth_account_id)
    return unless oauth_account

    profile = oauth_account.overwatch_api_profile
    return unless profile

    oauth_account.avatar_url = profile.portrait_url
    oauth_account.level = profile.level
    oauth_account.rank = profile.rank
    oauth_account.level_url = profile.level_url
    oauth_account.star_url = profile.star_url

    if oauth_account.changed? && !oauth_account.save
      errors = oauth_account.errors.full_messages.join(', ')
      Rails.logger.error('SetProfileDataJob failed to update account ' \
                         "#{oauth_account}:\n\t#{errors}")
    end
  end
end
