class UsersController < ApplicationController
  before_action :authenticate_user!

  def settings
  end

  def update
    if current_user.update_attributes(user_params)
      flash[:notice] = 'Updated settings.'
    else
      error = current_user.errors.full_messages.join(', ')
      flash[:alert] = "Could not update settings: #{error}"
    end

    redirect_to settings_path
  end

  def user_params
    params.require(:user).permit(:time_zone)
  end
end
