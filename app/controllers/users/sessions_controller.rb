class Users::SessionsController < Devise::SessionsController
  def new
    redirect_to user_bnet_omniauth_authorize_path
  end

  def create
    return head :not_found if request.xhr?
    render text: "Not found", status: :not_found
  end

  def destroy
    super
  end
end
