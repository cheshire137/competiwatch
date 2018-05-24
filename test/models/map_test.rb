require 'test_helper'

class MapTest < ActiveSupport::TestCase
  test 'requires name' do
    map = Map.new

    refute_predicate map, :valid?
    assert_includes map.errors.messages[:name], "can't be blank"
  end

  test 'requires positive first_season' do
    map = Map.new(first_season: -1)

    refute_predicate map, :valid?
    assert_includes map.errors.messages[:first_season], 'must be greater than 0'
  end

  test 'requires integer first_season' do
    map = Map.new(first_season: 3.3)

    refute_predicate map, :valid?
    assert_includes map.errors.messages[:first_season], 'must be an integer'
  end

  test 'requires unique name' do
    map1 = create(:map)
    map2 = Map.new(name: map1.name)

    refute_predicate map2, :valid?
    assert_includes map2.errors.messages[:name], 'has already been taken'
  end

  test 'requires map type' do
    map = Map.new

    refute_predicate map, :valid?
    assert_includes map.errors.messages[:map_type], "can't be blank"
  end

  test 'requires valid map type' do
    map = Map.new(map_type: 'something')

    refute_predicate map, :valid?
    assert_includes map.errors.messages[:map_type], 'is not included in the list'
  end

  test 'sets slug based on name' do
    map = Map.create(name: 'Some Awesome Name', map_type: 'assault')

    assert_equal 'some-awesome-name', map.slug
  end
end
