class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def bnet
    auth = request.env['omniauth.auth']
    battletag = auth.info.battletag
    account = Account.where(provider: auth.provider, uid: auth.uid,
                            battletag: battletag).first_or_create

    if signed_in? && current_account != account
      account.parent_account_id = current_account.parent_account_id || current_account.id

      unless account.save
        errors = account.errors.full_messages.join(', ')
        message = "Could not link account #{battletag}: #{errors}"
        return redirect_to(root_path, alert: message)
      end
    end

    SetProfileDataJob.perform_later(account.id)

    if signed_in?
      redirect_to accounts_path, notice: "Successfully linked #{battletag}."
    elsif account.persisted?
      sign_in_and_redirect account, event: :authentication
    else
      message = "Failed to sign in via Battle.net as #{battletag}."
      redirect_to root_path, alert: message
    end
  end

  def failure
    redirect_to root_path
  end
end
