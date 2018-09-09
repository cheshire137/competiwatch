require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

  test 'responds with LETS_ENCRYPT_VALUE' do
    ENV['LETS_ENCRYPT_VALUE'] = 'something something'

    get '/.well-known/acme-challenge/123abc'

    assert_response :ok
    assert_equal 'something something', response.body
  end

  test 'help page loads for anonymous user' do
    get '/help'

    assert_response :ok
  end

  test 'app page loads for anonymous user' do
    get '/app'

    assert_response :ok
  end

  test 'about page loads for anonymous user' do
    get '/about'

    assert_response :ok
  end

  test 'help page loads for authenticated user' do
    account = create(:account)

    sign_in_as(account)
    get '/help'

    assert_response :ok
  end

  test 'app page loads for authenticated user' do
    account = create(:account)

    sign_in_as(account)
    get '/app'

    assert_response :ok
  end

  test 'about page loads for authenticated user' do
    account = create(:account)

    sign_in_as(account)
    get '/about'

    assert_response :ok
  end
end
