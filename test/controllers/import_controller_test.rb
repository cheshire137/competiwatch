require 'test_helper'

class ImportControllerTest < ActionDispatch::IntegrationTest
  test 'import form requires login' do
    get '/import/3/SomeUser-1234'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'loads for your own account' do
    oauth_account = create(:oauth_account)

    sign_in_as(oauth_account)
    get "/import/3/#{oauth_account.to_param}"

    assert_response :ok
  end

  test "404s for another user's account" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)

    sign_in_as(oauth_account1)
    get "/import/3/#{oauth_account2.to_param}"

    assert_response :not_found
  end

  test 'imports matches to your account' do
    oauth_account = create(:oauth_account)
    csv = fixture_file_upload('files/valid-match-import.csv')
    season = 5

    assert_difference "oauth_account.matches.in_season(#{season}).count", 6 do
      sign_in_as(oauth_account)
      post "/import/#{season}/#{oauth_account.to_param}", params: { csv: csv }
    end

    assert_redirected_to matches_path(season, oauth_account)
  end

  test 'shows error when import fails for your account' do
    oauth_account = create(:oauth_account)
    season = 4

    assert_no_difference 'Match.count' do
      sign_in_as(oauth_account)
      post "/import/#{season}/#{oauth_account.to_param}"
    end

    assert_redirected_to import_path(season, oauth_account)
    assert_equal 'No CSV file was provided.', flash[:alert]
  end

  test "will not import matches to another user's account" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)
    csv = fixture_file_upload('files/valid-match-import.csv')

    assert_no_difference 'Match.count' do
      sign_in_as(oauth_account1)
      post "/import/3/#{oauth_account2.to_param}", params: { csv: csv }
    end

    assert_response :not_found
  end
end
