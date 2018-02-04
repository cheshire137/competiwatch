class ChangePlacementRank < ActiveRecord::Migration[5.1]
  def up
    remove_column :matches, :prior_rank
    change_column_null :matches, :map_id, true
    change_column_null :matches, :placement, true
    change_column_default :matches, :placement, nil
    change_column_null :matches, :result, true
    change_column_null :matches, :time_of_day, true
    change_column_null :matches, :day_of_week, true
    change_column_null :matches, :time, true
  end

  def down
    change_column_null :matches, :time, false
    change_column_null :matches, :day_of_week, false
    change_column_null :matches, :time_of_day, false
    change_column_null :matches, :result, false
    change_column_default :matches, :placement, false
    change_column_null :matches, :placement, false
    change_column_null :matches, :map_id, false
    add_column :matches, :prior_rank, :integer
  end
end
