require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test 'responds with LETS_ENCRYPT_VALUE' do
    ENV['LETS_ENCRYPT_VALUE'] = 'something something'

    get '/.well-known/acme-challenge/123abc'

    assert_response :ok
    assert_equal 'something something', response.body
  end
end
