require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

  test '404s for non-admin' do
    user = create(:user)
    oauth_account = create(:oauth_account, user: user)

    sign_in_as(oauth_account)
    get '/admin'

    assert_response :not_found
  end

  test '404s for anonymous user' do
    get '/admin'

    assert_response :not_found
  end

  test 'loads successfully for admin' do
    user = create(:user, admin: true)
    oauth_account = create(:oauth_account, user: user)
    userless_oauth_account = create(:oauth_account, user: nil)

    sign_in_as(oauth_account)
    get '/admin'

    assert_response :ok
    assert_select 'button', text: /#{oauth_account.battletag}/
    assert_select 'li', text: userless_oauth_account.battletag
  end

  test 'non-admin users cannot update season' do
    user = create(:user)
    oauth_account = create(:oauth_account, user: user)
    season = seasons(:one)

    sign_in_as(oauth_account)
    put '/admin/season', params: {
      season_id: season.id, update_season: { max_rank: 1234 }
    }

    assert_response :not_found
    assert_equal seasons(:one).max_rank, season.reload.max_rank
  end

  test 'non-admin users cannot create a season' do
    user = create(:user)
    oauth_account = create(:oauth_account, user: user)

    assert_no_difference 'Season.count' do
      sign_in_as(oauth_account)
      post '/admin/season', params: {
        create_season: { max_rank: 1234, number: 3 }
      }
    end

    assert_response :not_found
  end

  test 'non-admin users cannot delete a season' do
    user = create(:user)
    oauth_account = create(:oauth_account, user: user)
    season = seasons(:two)

    assert_no_difference 'Season.count' do
      sign_in_as(oauth_account)
      delete '/admin/season', params: { season_id: season.id }
    end

    assert_response :not_found
  end

  test 'non-admin cannot merge users' do
    primary_user = create(:user)
    secondary_user = create(:user)
    user = create(:user)
    oauth_account = create(:oauth_account, user: user)

    assert_no_difference 'User.count' do
      sign_in_as(oauth_account)
      post '/admin/merge-users', params: {
        primary_user_id: primary_user.id,
        secondary_user_id: secondary_user.id
      }
    end

    assert_response :not_found
  end

  test 'non-admin cannot edit accounts' do
    oauth_account = create(:oauth_account)
    user = create(:user)
    value_before = oauth_account.user

    sign_in_as(oauth_account)
    post '/admin/update-account', params: {
      user_id: user.id, oauth_account_id: oauth_account.id
    }

    assert_response :not_found
    assert_equal value_before, oauth_account.reload.user
  end

  test 'admin gets warning if user ID is not specified when editing an account' do
    admin_user = create(:user, admin: true)
    admin_account = create(:oauth_account, user: admin_user)

    sign_in_as(admin_account)
    post '/admin/update-account', params: { oauth_account_id: admin_account.id }

    assert_nil flash[:notice]
    assert_equal 'Please specify a user and an account.', flash[:error]
    assert_equal admin_user, admin_account.reload.user
    assert_redirected_to admin_path
  end

  test 'admin gets warning if a user ID is not specified when merging users' do
    admin_user = create(:user, admin: true)
    admin_account = create(:oauth_account, user: admin_user)

    assert_no_difference 'User.count' do
      sign_in_as(admin_account)
      post '/admin/merge-users', params: { primary_user_id: admin_user.id }
    end

    assert_nil flash[:notice]
    assert_equal 'Please choose a primary and a secondary user.', flash[:error]
    assert_redirected_to admin_path
  end

  test 'admin can update season' do
    admin_user = create(:user, admin: true)
    admin_account = create(:oauth_account, user: admin_user)
    season = seasons(:two)

    sign_in_as(admin_account)
    put '/admin/season', params: {
      season_id: season.id,
      update_season: { max_rank: 6001, started_on: '2018-02-28', ended_on: '2018-05-15' }
    }

    assert_redirected_to admin_path
    assert_equal "Successfully updated season #{season}.", flash[:notice]
    assert_nil flash[:error]
    assert_equal 6001, season.reload.max_rank
    assert_equal Date.parse('2018-02-28'), season.started_on
    assert_equal Date.parse('2018-05-15'), season.ended_on
  end

  test 'admin users can delete seasons' do
    admin_user = create(:user, admin: true)
    admin_account = create(:oauth_account, user: admin_user)
    season = seasons(:two)

    assert_difference 'Season.count', -1 do
      sign_in_as(admin_account)
      delete '/admin/season', params: { season_id: season.id }
    end

    assert_redirected_to admin_path
    assert_equal "Successfully deleted season #{season}.", flash[:notice]
    refute Season.exists?(season.id)
  end

  test 'admin users can create seasons' do
    admin_user = create(:user, admin: true)
    admin_account = create(:oauth_account, user: admin_user)

    assert_difference 'Season.count' do
      sign_in_as(admin_account)
      post '/admin/season', params: { create_season: {
        max_rank: 5500, started_on: '2017-04-10', number: 3
      } }
    end

    assert_redirected_to admin_path
    assert_equal 'Successfully created season 3.', flash[:notice]
    season = Season.find_by_number(3)
    refute_nil season
  end

  test 'admin can merge two users' do
    primary_user = create(:user)
    secondary_user = create(:user)
    primary_account = create(:oauth_account, user: primary_user)
    secondary_account = create(:oauth_account, user: secondary_user)
    admin_user = create(:user, admin: true)
    admin_account = create(:oauth_account, user: admin_user)

    assert_difference 'User.count', -1 do
      sign_in_as(admin_account)
      post '/admin/merge-users', params: {
        primary_user_id: primary_user.id,
        secondary_user_id: secondary_user.id
      }
    end

    assert_nil flash[:error]
    assert_equal "Successfully merged user #{secondary_user} with #{primary_user}.", flash[:notice]
    assert_redirected_to admin_path
    refute User.exists?(secondary_user.id)
    assert User.exists?(primary_user.id)
    assert_equal primary_user, secondary_account.reload.user
  end

  test 'admin can change which user an account is tied to' do
    oauth_account = create(:oauth_account)
    user = create(:user)
    admin_user = create(:user, admin: true)
    admin_account = create(:oauth_account, user: admin_user)

    sign_in_as(admin_account)
    post '/admin/update-account', params: {
      user_id: user.id, oauth_account_id: oauth_account.id
    }

    assert_equal "Successfully tied account #{oauth_account} to user #{user}.", flash[:notice]
    assert_redirected_to admin_path
    assert_equal user, oauth_account.reload.user
  end
end
