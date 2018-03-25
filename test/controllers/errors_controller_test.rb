require 'test_helper'

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test 'undefined route 404s' do
    assert_routing '/whatevs', controller: 'errors', action: 'not_found', path: 'whatevs'
  end

  test '404 page responds with 404' do
    get '/404'

    assert_response :not_found
    assert_template layout: 'errors'
  end

  test '500 page responds with 500' do
    get '/500'

    assert_response 500
    assert_template layout: 'errors'
  end

  test '403 page responds with 403' do
    get '/403'

    assert_response :forbidden
    assert_template layout: 'errors'
  end

  test '401 page responds with 401' do
    get '/401'

    assert_response :unauthorized
    assert_template layout: 'errors'
  end

  test '422 page responds with 422' do
    get '/422'

    assert_response :unprocessable_entity
    assert_template layout: 'errors'
  end
end
