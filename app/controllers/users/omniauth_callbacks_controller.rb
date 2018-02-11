class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def bnet
    auth = request.env['omniauth.auth']
    user = if signed_in?
      current_user
    else
      User.find_by_battletag(auth.info.battletag) || User.new(battletag: auth.info.battletag)
    end

    if user.new_record? && !user.save
      return redirect_to(root_path, alert: 'Failed to sign in via Battle.net.')
    end

    account = OauthAccount.where(provider: auth.provider, uid: auth.uid).first_or_initialize
    if account.persisted? && account.user != user
      message = 'That account is already linked to another user.'
      return redirect_to(settings_path, alert: message) if signed_in?
      return redirect_to(root_path, alert: message)
    end

    account.user = user
    account.battletag = auth.info.battletag

    if account.changed? && !account.save
      flash[:alert] = "Failed to connect Battle.net account #{auth.info.battletag}."
    end

    if signed_in?
      redirect_to accounts_path, notice: "Successfully linked #{account.battletag}."
    else
      sign_in_and_redirect user, event: :authentication
    end
  end

  def failure
    redirect_to root_path
  end
end
