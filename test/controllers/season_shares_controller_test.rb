require 'test_helper'

class SeasonSharesControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

  test 'can view your own shares' do
    user = create(:user)
    account1 = create(:account, user: user)
    account2 = create(:account, user: user)
    create(:season, number: 3)
    create(:match, account: account1, season: 1)
    create(:match, account: account1, season: 2)
    create(:match, account: account2, season: 3)
    create(:season_share, account: account1, season: 1)
    create(:season_share, account: account1, season: 2)

    sign_in_as(account1)
    get '/shared-seasons'

    assert_response :ok
    assert_select '.season-share-list-item',
      text: /Season 2\s+1\s+match\s+Publicly visible/
    assert_select '.season-share-list-item',
      text: /Season 1\s+1\s+match\s+Publicly visible/
    assert_select '.season-share-list-item',
      text: /Season 3\s+1\s+match\s+Only visible to you/
  end

  test 'requires login for viewing season shares' do
    get '/shared-seasons'

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'create redirects for anonymous user' do
    account = create(:account)

    assert_no_difference 'SeasonShare.count' do
      post "/season/1/#{account.to_param}/share"
    end

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test '404s trying to create a season share for someone else' do
    account1 = create(:account)
    account2 = create(:account)

    assert_no_difference 'SeasonShare.count' do
      sign_in_as(account1)
      post "/season/2/#{account2.to_param}/share"
    end

    assert_response :not_found
  end

  test 'can create a season share for your account' do
    account = create(:account)

    assert_difference 'account.season_shares.count' do
      sign_in_as(account)
      post "/season/2/#{account.to_param}/share"
    end

    assert_redirected_to matches_path(2, account)
  end

  test 'destroy redirects for anonymous user' do
    account = create(:account)
    create(:season_share, season: 2, account: account)

    assert_no_difference 'SeasonShare.count' do
      delete "/season/2/#{account.to_param}/share"
    end

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'can delete a season share for your account' do
    account = create(:account)
    season_share = create(:season_share, season: 2, account: account)

    assert_difference 'account.season_shares.count', -1 do
      sign_in_as(account)
      delete "/season/2/#{account.to_param}/share"
    end

    assert_redirected_to matches_path(2, account)
    refute SeasonShare.exists?(season_share.id)
  end

  test '404s trying to delete a season share for someone else' do
    account1 = create(:account)
    account2 = create(:account)
    season_share = create(:season_share, season: 1, account: account2)

    assert_no_difference 'SeasonShare.count' do
      sign_in_as(account1)
      post "/season/1/#{account2.to_param}/share"
    end

    assert_response :not_found
    assert SeasonShare.exists?(season_share.id)
  end
end
