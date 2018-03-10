class SetAvatarJob < ApplicationJob
  queue_as :default

  def perform(*args)
    oauth_account_id = args.first
    return unless oauth_account_id

    oauth_account = OAuthAccount.find_by_id(oauth_account_id)
    return unless oauth_account

    profile = oauth_account.overwatch_api_profile
    if profile && profile.portrait_url
      oauth_account.avatar_url = profile.portrait_url

      unless oauth_account.save
        errors = oauth_account.errors.full_messages.join(', ')
        Rails.logger.error("SetAvatarJob failed to set URL:\n\t#{errors}")
      end
    end
  end
end
