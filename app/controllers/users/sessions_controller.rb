class Users::SessionsController < Devise::SessionsController
  def destroy
    super
  end
end
