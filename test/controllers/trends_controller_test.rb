require 'test_helper'

class TrendsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @past_season = seasons(:one)
    @season = seasons(:three)
    @future_season = create(:season, started_on: 2.months.from_now)
    @user = create(:user)
    @oauth_account = create(:oauth_account, user: @user)
    @hero1 = create(:hero)
    @hero2 = create(:hero)
    @match1 = create(:match, oauth_account: @oauth_account, season: @season.number)
    @match1.heroes << @hero1
    @match2 = create(:match, oauth_account: @oauth_account, season: @season.number,
                     prior_match: @match1)
    @friend = create(:friend, user: @user)
    @match1_friend = create(:match_friend, match: @match1, friend: @friend)
    @match2_friend = create(:match_friend, match: @match2, friend: @friend)
    @match2.heroes << @hero2
  end

  test 'says season has not started for future season' do
    sign_in_as(@oauth_account)
    get "/trends/#{@future_season}/#{@oauth_account.to_param}"

    assert_select '.blankslate', text: /Season #{@future_season} has not started yet./
  end

  test 'says when user has not logged matches in past season' do
    sign_in_as(@oauth_account)
    get "/trends/#{@past_season}/#{@oauth_account.to_param}"

    assert_select '.blankslate',
      text: /#{@oauth_account}\s+did not log\s+any competitive matches in season #{@past_season}./
  end

  test 'index page 404s for anonymous user when season not shared' do
    get "/trends/#{@season}/#{@oauth_account.to_param}"

    assert_response :not_found
  end

  test 'index page loads for owner' do
    sign_in_as(@oauth_account)
    get "/trends/#{@season}/#{@oauth_account.to_param}"

    assert_response :ok
  end

  test 'index page loads for anonymous user when season is shared' do
    create(:season_share, oauth_account: @oauth_account, season: @season.number)

    get "/trends/#{@season}/#{@oauth_account.to_param}"

    assert_response :ok
  end

  test 'index page loads for a user who is not the owner when season is shared' do
    create(:season_share, oauth_account: @oauth_account, season: @season.number)
    other_account = create(:oauth_account)

    sign_in_as(other_account)
    get "/trends/#{@season}/#{@oauth_account.to_param}"

    assert_response :ok
  end
end
