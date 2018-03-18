require 'test_helper'

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  fixtures :seasons

  test 'non-admin cannot merge users' do
    primary_user = create(:user)
    secondary_user = create(:user)
    account = create(:account)

    assert_no_difference 'User.count' do
      sign_in_as(account)
      post '/admin/users/merge', params: {
        primary_user_id: primary_user.id,
        secondary_user_id: secondary_user.id
      }
    end

    assert_response :not_found
  end

  test 'admin gets warning if a user ID is not specified when merging users' do
    user = create(:user)
    admin_account = create(:account, admin: true)

    assert_no_difference 'User.count' do
      sign_in_as(admin_account)
      post '/admin/users/merge', params: { primary_user_id: user.id }
    end

    assert_nil flash[:notice]
    assert_equal 'Please choose a primary and a secondary user.', flash[:error]
    assert_redirected_to admin_path
  end

  test 'admin can merge two users' do
    primary_user = create(:user)
    secondary_user = create(:user)
    primary_account = create(:account, user: primary_user)
    secondary_account = create(:account, user: secondary_user)
    admin_account = create(:account, admin: true)

    assert_difference 'User.count', -1 do
      sign_in_as(admin_account)
      post '/admin/users/merge', params: {
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
end
