class AddFirstSeasonToHeroes < ActiveRecord::Migration[5.1]
  def change
    add_column :heroes, :first_season, :integer, null: false, default: 1
    add_index :heroes, :first_season
  end
end
