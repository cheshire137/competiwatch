require 'test_helper'

class ExportControllerTest < ActionDispatch::IntegrationTest
  test "cannot export another user's season" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)

    sign_in_as(oauth_account1)
    post "/season/5/#{oauth_account2.to_param}/export.csv"

    assert_response :not_found
  end

  test 'can export your own season' do
    oauth_account = create(:oauth_account)

    sign_in_as(oauth_account)
    post "/season/5/#{oauth_account.to_param}/export.csv"

    assert_response :ok
  end
end
