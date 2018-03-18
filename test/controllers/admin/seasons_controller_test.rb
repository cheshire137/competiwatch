require 'test_helper'

class Admin::SeasonsControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

  test 'non-admin users cannot update season' do
    account = create(:account)
    season = seasons(:one)

    sign_in_as(account)
    put '/admin/season', params: {
      season_id: season.id, update_season: { max_rank: 1234 }
    }

    assert_response :not_found
    assert_equal seasons(:one).max_rank, season.reload.max_rank
  end

  test 'non-admin users cannot create a season' do
    account = create(:account)

    assert_no_difference 'Season.count' do
      sign_in_as(account)
      post '/admin/season', params: {
        create_season: { max_rank: 1234, number: 3 }
      }
    end

    assert_response :not_found
  end

  test 'non-admin users cannot delete a season' do
    account = create(:account)
    season = seasons(:two)

    assert_no_difference 'Season.count' do
      sign_in_as(account)
      delete '/admin/season', params: { season_id: season.id }
    end

    assert_response :not_found
  end

  test 'admin can update season' do
    admin_account = create(:account, admin: true)
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
    admin_account = create(:account, admin: true)
    season = seasons(:two)

    assert_difference 'Season.count', -1 do
      sign_in_as(admin_account)
      delete '/admin/season', params: { season_id: season.id }
    end

    assert_redirected_to admin_path
    assert_equal "Successfully deleted season #{season}.", flash[:notice]
    refute Season.exists?(season.id)
  end

  test 'admin accounts can create seasons' do
    admin_account = create(:account, admin: true)

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
end
