class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def bnet
    auth = request.env['omniauth.auth']
    battletag = auth.info.battletag
    account = OAuthAccount.where(provider: auth.provider, uid: auth.uid,
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
        battletags = other_user.oauth_accounts.pluck(:battletag) -
          current_user.oauth_accounts.pluck(:battletag)
        success = if other_user.merge_with(current_user)
          account.user = current_user
          account.save
        end
        message_opts = if success
          current_user.reload
          account.reload

          SetProfileDataJob.perform_later(account.id)

          { notice: "Successfully linked #{battletags.join(', ')}." }
        else
          { alert: "Could not link account #{battletag}." }
        end
        return redirect_to(accounts_path, message_opts)
      end
    end

    if account.new_record? || account.user.nil?
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
    user.default_oauth_account ||= account
    user.save

    SetProfileDataJob.perform_later(account.id)

    if signed_in?
      redirect_to accounts_path, notice: "Successfully linked #{battletag}."
    else
      session[:current_account_id] = account.id
      sign_in_and_redirect account.user, event: :authentication
    end
  end

  def failure
    redirect_to root_path
  end
end
