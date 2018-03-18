class Admin::AccountsController < ApplicationController
  before_action :require_admin

  def update
    unless params[:user_id] && params[:account_id]
      flash[:error] = 'Please specify a user and an account.'
      return redirect_to(admin_path)
    end

    user = User.find(params[:user_id])
    account = Account.find(params[:account_id])
    account.user = user

    if account.save
      flash[:notice] = "Successfully tied account #{account} to user #{user}."
    else
      flash[:error] = "Could not tie account #{account} to user #{user}: " +
                      account.errors.full_messages.join(', ')
    end

    redirect_to admin_path
  end
end
