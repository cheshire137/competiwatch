require 'test_helper'

class SeasonsControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

  test 'can wipe your own season' do
    account = create(:account)
    season = 2
    match1 = create(:match, account: account, season: season)
    match2 = create(:match, account: account, season: season)
    match3 = create(:match, account: account, season: season + 1)
    match4 = create(:match, season: season)

    assert_difference 'Match.count', -2 do
      sign_in_as(account)
      delete "/season/#{season}/#{account.to_param}"
    end

    assert_redirected_to matches_path(season, account)
    refute Match.exists?(match1.id)
    refute Match.exists?(match2.id)
    assert Match.exists?(match3.id), 'should not delete my match from another season'
    assert Match.exists?(match4.id), "should not delete another account's match"
  end

  test "cannot wipe another user's season" do
    account1 = create(:account)
    account2 = create(:account)
    match1 = create(:match, account: account1, season: 2)
    match2 = create(:match, account: account1, season: 2)

    assert_no_difference 'Match.count' do
      sign_in_as(account2)
      delete "/season/2/#{account1.to_param}"
    end

    assert_response :not_found
  end

  test 'can list seasons to wipe in your accounts' do
    user = create(:user)
    account1 = create(:account, user: user, battletag: 'ANeatAccount#123')
    account2 = create(:account, user: user, battletag: 'HowFunAndNice#456')

    sign_in_as(account1)
    get '/seasons/choose-season-to-wipe'

    assert_response :ok
    assert_includes response.body, account1.battletag
    assert_includes response.body, account2.battletag
  end

  test "cannot confirm wiping another user's season" do
    account1 = create(:account)
    account2 = create(:account)

    sign_in_as(account2)
    get "/season/2/#{account1.to_param}/confirm-wipe"

    assert_response :not_found
  end

  test 'can confirm wiping my season' do
    account = create(:account)
    match1 = create(:match, account: account, rank: 1234, season: 2)
    match2 = create(:match, account: account, rank: 4567, season: 2)

    sign_in_as(account)
    get "/season/#{2}/#{account.to_param}/confirm-wipe"

    assert_response :ok
    assert_select 'span', text: match1.rank.to_s
    assert_select 'span', text: match2.rank.to_s
  end
end
