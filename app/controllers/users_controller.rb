class UsersController < ApplicationController
  before_action :authenticate_account!

  def settings
  end
end
