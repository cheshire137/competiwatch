class AccountsController < ApplicationController
  before_action :authenticate_user!, except: [:avatar, :show]
  before_action :set_account, only: [:destroy, :set_default, :show, :update, :avatar]
  before_action :ensure_account_is_mine, only: [:destroy, :set_default, :update]

  def index
    @accounts = current_user.accounts.includes(:user).order_by_battletag
  end

  def set_default
    current_user.default_account = @account

    if current_user.save
      flash[:notice] = "Your default account is now #{@account}."
    else
      flash[:error] = 'Could not update your default account at this time.'
    end

    redirect_to accounts_path
  end

  def update
    @account.assign_attributes account_params

    if @account.save
      flash[:notice] = "Successfully updated #{@account}."
    else
      flash[:error] = "Could not update #{@account}: " +
                      @account.errors.full_messages.join(', ')
    end

    redirect_to accounts_path
  end

  def destroy
    unless @account.can_be_unlinked?
      flash[:error] = "#{@account} cannot be unlinked from your account."
      return redirect_to(accounts_path)
    end

    @account.user = nil
    if @account.save
      flash[:notice] = "Successfully disconnected #{@account}."
    else
      flash[:error] = "Could not disconnect #{@account}."
    end
    redirect_to accounts_path
  end

  private

  def account_params
    params.require(:account).permit(:platform)
  end
end
