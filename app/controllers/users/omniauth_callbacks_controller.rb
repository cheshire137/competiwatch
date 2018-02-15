class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def bnet
    auth = request.env['omniauth.auth']
    account = OauthAccount.where(provider: auth.provider, uid: auth.uid,
                                 battletag: auth.info.battletag).first_or_initialize
    user = if account.persisted?
      account.user
    else
      User.new(battletag: auth.info.battletag)
    end

    if signed_in? && user.persisted? && user != current_user
      message = 'That account is already linked to another user.'
      return redirect_to(accounts_path, alert: message)
    end

    if user.new_record? && !user.save
      message = "Failed to sign in via Battle.net as #{auth.info.battletag}."
      return redirect_to(root_path, alert: message)
    end

    account.user = user
    if (account.new_record? || account.changed?) && !account.save
      message = "Failed to sign in via Battle.net as #{auth.info.battletag}."
      return redirect_to(root_path, alert: message)
    end

    if signed_in?
      redirect_to accounts_path, notice: "Successfully linked #{account.battletag}."
    else
      session[:sign_in_battletag] = account.battletag
      sign_in_and_redirect user, event: :authentication
    end
  end

  def failure
    redirect_to root_path
  end
end
