require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
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

    sign_in_as(oauth_account)
    get '/admin'

    assert_response :ok
  end

  test 'non-admin cannot link accounts' do
    primary_user = create(:user)
    secondary_user = create(:user)
    user = create(:user)
    oauth_account = create(:oauth_account, user: user)

    assert_no_difference 'User.count' do
      sign_in_as(oauth_account)
      post '/admin/link-accounts', params: {
        primary_user_id: primary_user.id,
        secondary_user_id: secondary_user.id
      }
    end

    assert_response :not_found
  end

  test 'admin can link accounts' do
    primary_user = create(:user)
    secondary_user = create(:user)
    primary_account = create(:oauth_account, user: primary_user)
    secondary_account = create(:oauth_account, user: secondary_user)
    admin_user = create(:user, admin: true)
    admin_account = create(:oauth_account, user: admin_user)

    assert_difference 'User.count', -1 do
      sign_in_as(admin_account)
      post '/admin/link-accounts', params: {
        primary_user_id: primary_user.id,
        secondary_user_id: secondary_user.id
      }
    end

    assert_nil flash[:error]
    assert_equal "Successfully linked #{secondary_account} with #{primary_account}.", flash[:notice]
    assert_redirected_to admin_path
    refute User.exists?(secondary_user.id)
    assert User.exists?(primary_user.id)
    assert_equal primary_user, secondary_account.reload.user
  end
end
