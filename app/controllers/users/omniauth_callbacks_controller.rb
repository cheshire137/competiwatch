class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def bnet
    auth = request.env['omniauth.auth']
    battletag = auth.info.battletag
    account = OauthAccount.where(provider: auth.provider, uid: auth.uid,
                                 battletag: battletag).first_or_initialize
    if account.persisted?
      if signed_in? && account.user.nil?
        account.user = current_user

        unless account.save
          message = "Could not link account #{battletag}."
          return redirect_to(accounts_path, alert: message)
        end
      end

      if signed_in? && account.user != current_user
        other_user = account.user
        success = if other_user.merge_with(current_user)
          account.user = current_user
          account.save
        end
        message_opts = if success
          { notice: "Successfully linked #{battletag}." }
        else
          { alert: "Could not link account #{battletag}." }
        end
        return redirect_to(accounts_path, message_opts)
      end
    else
      user = User.where(battletag: battletag).first_or_initialize

      if user.new_record? && !user.save
        message = "Failed to sign in via Battle.net as #{battletag}."
        return redirect_to(root_path, alert: message)
      end

      account.user = user
      unless account.save
        message = "Failed to sign in via Battle.net as #{battletag}."
        return redirect_to(root_path, alert: message)
      end
    end

    user = account.user
    user.default_oauth_account = account
    user.save

    if signed_in?
      redirect_to accounts_path, notice: "Successfully linked #{battletag}."
    else
      sign_in_and_redirect account.user, event: :authentication
    end
  end

  def failure
    redirect_to root_path
  end
end
