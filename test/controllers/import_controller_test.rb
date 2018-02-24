require 'test_helper'

class ImportControllerTest < ActionDispatch::IntegrationTest
  setup do
    @season = seasons(:two)
  end

  test 'import form requires login' do
    get "/import/#{@season}/SomeUser-1234"

    assert_response :redirect
    assert_redirected_to 'http://www.example.com/'
  end

  test 'loads for your own account' do
    oauth_account = create(:oauth_account)

    sign_in_as(oauth_account)
    get "/import/#{@season}/#{oauth_account.to_param}"

    assert_response :ok
  end

  test "404s for another user's account" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)

    sign_in_as(oauth_account1)
    get "/import/#{@season}/#{oauth_account2.to_param}"

    assert_response :not_found
  end

  test 'imports matches to your account' do
    create(:map, name: 'Watchpoint: Gibraltar')
    create(:map, name: 'Lijiang Tower')
    create(:map, name: 'Junkertown')
    create(:map, name: 'Hollywood')
    create(:map, name: 'Hanamura')
    user = create(:user)
    oauth_account = create(:oauth_account, user: user)
    csv = fixture_file_upload('files/valid-match-import.csv')

    assert_difference "user.friends.count", 3 do
      assert_difference "MatchFriend.count", 4 do
        assert_difference "oauth_account.matches.in_season(#{@season}).count", 6 do
          sign_in_as(oauth_account)
          post "/import/#{@season}/#{oauth_account.to_param}", params: { csv: csv }
        end
      end
    end

    assert_redirected_to matches_path(@season, oauth_account)

    matches = oauth_account.matches.in_season(@season).ordered_by_time
    expected = [
      { rank: 3932 },
      {
        rank: 3903, map: 'Watchpoint: Gibraltar', comment: 'red Junkrat, favored team',
        ally_leaver: false, ally_thrower: true, enemy_leaver: false, enemy_thrower: false,
        friend_names: %w[Jamie]
      },
      { rank: 3928, map: 'Lijiang Tower', comment: 'unfavored team', friend_names: %w[Jamie Rob] },
      {
        rank: 3954, map: 'Junkertown', comment: 'first game w/o perf. SR',
        ally_leaver: false, ally_thrower: false, enemy_leaver: false, enemy_thrower: false,
        friend_names: %w[Siege]
      },
      {
        rank: 3931, map: 'Hollywood', comment: 'overextending, feeding teammate',
        ally_leaver: false, ally_thrower: false, enemy_leaver: false, enemy_thrower: true
      },
      { rank: 3954, map: 'Hanamura', comment: 'favored' }
    ]
    expected.each_with_index do |details, i|
      rank = details[:rank]
      match = matches[i]
      refute_nil match, "should have a match with rank #{rank} in season #{@season}"

      unless i == 0
        assert_equal matches[i - 1], match.prior_match, 'should have a prior match'
      end

      details.each do |field, value|
        if field == :map
          refute_nil match.map, "rank #{rank} match should have a map"
          assert_equal value, match.map.name
        else
          assert_equal value, match.send(field)
        end
      end
    end
  end

  test 'shows error when import fails for your account' do
    oauth_account = create(:oauth_account)

    assert_no_difference 'Match.count' do
      sign_in_as(oauth_account)
      post "/import/#{@season}/#{oauth_account.to_param}"
    end

    assert_redirected_to import_path(@season, oauth_account)
    assert_equal 'No CSV file was provided.', flash[:alert]
  end

  test "will not import matches to another user's account" do
    oauth_account1 = create(:oauth_account)
    oauth_account2 = create(:oauth_account)
    csv = fixture_file_upload('files/valid-match-import.csv')

    assert_no_difference 'Match.count' do
      sign_in_as(oauth_account1)
      post "/import/#{@season}/#{oauth_account2.to_param}", params: { csv: csv }
    end

    assert_response :not_found
  end
end
