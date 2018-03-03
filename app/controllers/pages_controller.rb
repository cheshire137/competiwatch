class PagesController < ApplicationController
  def lets_encrypt
    render text: ENV['LETS_ENCRYPT_VALUE']
  end
end
