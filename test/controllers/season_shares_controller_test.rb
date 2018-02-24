require 'test_helper'

class SeasonSharesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @seasons = []
    8.times { @seasons << create(:season) }
  end

  test 'can view your own shares' do
    user = create(:user)
    oauth_account1 = create(:oauth_account, user: user)
    oauth_account2 = create(:oauth_account, user: user)
    create(:season_share, oauth_account: oauth_account1, season: 3)
    create(:season_share, oauth_account: oauth_account1, season: 5)
    create(:season_share, oauth_account: oauth_account2, season: 7)

    sign_in_as(oauth_account1)
    get '/shared-seasons'

    assert_response :ok
    assert_select 'li', text: /Season 1\s+Only visible to you/
    assert_select 'li', text: /Season 2\s+Only visible to you/
    assert_select 'li', text: /Season 3\s+Publicly visible/
    assert_select 'li', text: /Season 4\s+Only visible to you/
    assert_select 'li', text: /Season 5\s+Publicly visible/
    assert_select 'li', text: /Season 6\s+Only visible to you/
    assert_select 'li', text: /Season 7\s+Publicly visible/
    assert_select 'li', text: /Season 8\s+Only visible to you/
  end

  test 'requires login for viewing season shares' do
    get '/shared-seasons'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'create redirects for anonymous user' do
    oauth_account = create(:oauth_account)

    assert_no_difference 'SeasonShare.count' do
      post "/season/#{@seasons[0]}/#{oauth_account.to_param}/share"
    end

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test '404s trying to create a season share for someone else' do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)

    assert_no_difference 'SeasonShare.count' do
      sign_in_as(oauth_account1)
      post "/season/#{@seasons[0]}/#{oauth_account2.to_param}/share"
    end

    assert_response :not_found
  end

  test 'can create a season share for your account' do
    oauth_account = create(:oauth_account)

    assert_difference 'oauth_account.season_shares.count' do
      sign_in_as(oauth_account)
      post "/season/#{@seasons[0]}/#{oauth_account.to_param}/share"
    end

    assert_redirected_to matches_path(@seasons[0], oauth_account)
  end

  test 'destroy redirects for anonymous user' do
    oauth_account = create(:oauth_account)
    create(:season_share, season: @seasons[0].number, oauth_account: oauth_account)

    assert_no_difference 'SeasonShare.count' do
      delete "/season/#{@seasons[0]}/#{oauth_account.to_param}/share"
    end

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'can delete a season share for your account' do
    oauth_account = create(:oauth_account)
    season_share = create(:season_share, season: @seasons[0].number, oauth_account: oauth_account)

    assert_difference 'oauth_account.season_shares.count', -1 do
      sign_in_as(oauth_account)
      delete "/season/#{@seasons[0]}/#{oauth_account.to_param}/share"
    end

    assert_redirected_to matches_path(@seasons[0], oauth_account)
    refute SeasonShare.exists?(season_share.id)
  end

  test '404s trying to delete a season share for someone else' do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)
    season_share = create(:season_share, season: @seasons[0].number, oauth_account: oauth_account2)

    assert_no_difference 'SeasonShare.count' do
      sign_in_as(oauth_account1)
      post "/season/#{@seasons[0]}/#{oauth_account2.to_param}/share"
    end

    assert_response :not_found
    assert SeasonShare.exists?(season_share.id)
  end
end
