require 'test_helper'

class SeasonSharesControllerTest < ActionDispatch::IntegrationTest
  test 'create redirects for anonymous user' do
    oauth_account = create(:oauth_account)

    assert_no_difference 'SeasonShare.count' do
      post "/season/1/#{oauth_account.to_param}/share"
    end

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test '404s trying to create a season share for someone else' do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)

    assert_no_difference 'SeasonShare.count' do
      sign_in_as(oauth_account1)
      post "/season/1/#{oauth_account2.to_param}/share"
    end

    assert_response :not_found
  end

  test 'can create a season share for your account' do
    oauth_account = create(:oauth_account)

    assert_difference 'oauth_account.season_shares.count' do
      sign_in_as(oauth_account)
      post "/season/1/#{oauth_account.to_param}/share"
    end

    assert_redirected_to matches_path(1, oauth_account)
  end

  test 'destroy redirects for anonymous user' do
    oauth_account = create(:oauth_account)
    create(:season_share, season: 1, oauth_account: oauth_account)

    assert_no_difference 'SeasonShare.count' do
      delete "/season/1/#{oauth_account.to_param}/share"
    end

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'can delete a season share for your account' do
    oauth_account = create(:oauth_account)
    season_share = create(:season_share, season: 1, oauth_account: oauth_account)

    assert_difference 'oauth_account.season_shares.count', -1 do
      sign_in_as(oauth_account)
      delete "/season/1/#{oauth_account.to_param}/share"
    end

    assert_redirected_to matches_path(1, oauth_account)
    refute SeasonShare.exists?(season_share.id)
  end

  test '404s trying to delete a season share for someone else' do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)
    season_share = create(:season_share, season: 1, oauth_account: oauth_account2)

    assert_no_difference 'SeasonShare.count' do
      sign_in_as(oauth_account1)
      post "/season/1/#{oauth_account2.to_param}/share"
    end

    assert_response :not_found
    assert SeasonShare.exists?(season_share.id)
  end
end
