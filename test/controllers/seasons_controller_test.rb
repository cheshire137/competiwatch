require 'test_helper'

class SeasonsControllerTest < ActionDispatch::IntegrationTest
  test 'can wipe your own season' do
    oauth_account = create(:oauth_account)
    season = 3
    match1 = create(:match, oauth_account: oauth_account, season: season)
    match2 = create(:match, oauth_account: oauth_account, season: season)
    match3 = create(:match, oauth_account: oauth_account, season: season + 1)
    match4 = create(:match, season: season)

    assert_difference 'Match.count', -2 do
      sign_in_as(oauth_account)
      delete "/season/#{season}/#{oauth_account.to_param}"
    end

    assert_redirected_to matches_path(season, oauth_account)
    refute Match.exists?(match1.id)
    refute Match.exists?(match2.id)
    assert Match.exists?(match3.id), 'should not delete my match from another season'
    assert Match.exists?(match4.id), "should not delete another account's match"
  end

  test "cannot wipe another user's season" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)
    season = 5
    match1 = create(:match, oauth_account: oauth_account1, season: season)
    match2 = create(:match, oauth_account: oauth_account1, season: season)

    assert_no_difference 'Match.count' do
      sign_in_as(oauth_account2)
      delete "/season/#{season}/#{oauth_account1.to_param}"
    end

    assert_response :not_found
  end

  test 'can list seasons to wipe in your accounts' do
    user = create(:user)
    oauth_account1 = create(:oauth_account, user: user, battletag: 'ANeatAccount#123')
    oauth_account2 = create(:oauth_account, user: user, battletag: 'HowFunAndNice#456')

    sign_in_as(oauth_account1)
    get '/seasons/choose-season-to-wipe'

    assert_response :ok
    assert_includes response.body, oauth_account1.battletag
    assert_includes response.body, oauth_account2.battletag
  end

  test "cannot confirm wiping another user's season" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)

    sign_in_as(oauth_account2)
    get "/season/4/#{oauth_account1.to_param}/confirm-wipe"

    assert_response :not_found
  end

  test 'can confirm wiping my season' do
    oauth_account = create(:oauth_account)
    season = 4
    match1 = create(:match, oauth_account: oauth_account, rank: 1234, season: season)
    match2 = create(:match, oauth_account: oauth_account, rank: 4567, season: season)

    sign_in_as(oauth_account)
    get "/season/#{season}/#{oauth_account.to_param}/confirm-wipe"

    assert_response :ok
    assert_select 'span', text: match1.rank.to_s
    assert_select 'span', text: match2.rank.to_s
  end
end
