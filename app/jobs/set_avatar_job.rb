class SetAvatarJob < ApplicationJob
  queue_as :default

  def perform(*args)
    oauth_account = args.first
    return unless oauth_account

    profile = oauth_account.overwatch_api_profile
    if profile && profile.portrait_url
      oauth_account.avatar_url = profile.portrait_url
      oauth_account.save
    end
  end
end
