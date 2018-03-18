class Admin::UsersController < ApplicationController
  before_action :require_admin

  def merge
    unless params[:primary_user_id] && params[:secondary_user_id]
      flash[:error] = 'Please choose a primary and a secondary user.'
      return redirect_to(admin_path)
    end

    secondary_user = User.find(params[:secondary_user_id])
    primary_user = User.find(params[:primary_user_id])

    if secondary_user.merge_with(primary_user)
      flash[:notice] = "Successfully merged user #{secondary_user} with #{primary_user}."
    else
      flash[:error] = "Failed to merge user #{secondary_user} with #{primary_user}."
    end

    redirect_to admin_path
  end
end
