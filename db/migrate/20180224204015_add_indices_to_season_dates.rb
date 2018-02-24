class AddIndicesToSeasonDates < ActiveRecord::Migration[5.1]
  def change
    add_index :seasons, [:started_on, :ended_on]
  end
end
