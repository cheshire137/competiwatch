class PagesController < ApplicationController
  def lets_encrypt
    render plain: ENV['LETS_ENCRYPT_VALUE']
  end
end
