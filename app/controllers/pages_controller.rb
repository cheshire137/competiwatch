class PagesController < ApplicationController
  def about
  end

  def lets_encrypt
    render plain: ENV['LETS_ENCRYPT_VALUE']
  end

  def help
  end
end
