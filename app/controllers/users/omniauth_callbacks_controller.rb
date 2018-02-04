class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def bnet
    auth = request.env['omniauth.auth']
    user = User.find_by_battletag(auth.info.battletag) || User.new(battletag: auth.info.battletag)

    unless user.save
      return redirect_to(root_path, alert: 'Failed to sign in via Battle.net.')
    end

    account = OauthAccount.where(provider: auth.provider, uid: auth.uid).first_or_initialize
    if account.persisted? && account.user != user
      return redirect_to(root_path, alert: 'That account is already linked to another user.')
    end

    account.user = user
    account.battletag = auth.info.battletag

    if account.changed? && !account.save
      flash[:alert] = 'Failed to link with your Battle.net account.'
    end

    sign_in_and_redirect user, event: :authentication
  end

  def failure
    redirect_to root_path
  end
end
