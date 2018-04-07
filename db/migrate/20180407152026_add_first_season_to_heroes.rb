class AddFirstSeasonToHeroes < ActiveRecord::Migration[5.1]
  def change
    add_column :heroes, :first_season, :integer
  end
end
