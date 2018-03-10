require 'test_helper'

class ExportControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

  setup do
    @season = seasons(:two)
  end

  test 'index page redirects anonymous user' do
    get '/export'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test "cannot export another user's season" do
    account1 = create(:account)
    account2 = create(:account)

    sign_in_as(account1)
    post "/season/#{@season}/#{account2.to_param}/export.csv"

    assert_response :not_found
  end

  test 'can export your own season' do
    account = create(:account)

    sign_in_as(account)
    post "/season/#{@season}/#{account.to_param}/export.csv"

    assert_response :ok
  end
end
