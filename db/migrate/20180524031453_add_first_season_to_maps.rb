class AddFirstSeasonToMaps < ActiveRecord::Migration[5.1]
  def change
    add_column :maps, :first_season, :integer, null: false, default: 1
    add_index :maps, :first_season
  end
end
