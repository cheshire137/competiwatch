class AddMoreMatchFields < ActiveRecord::Migration[5.1]
  def change
    add_column :matches, :prior_match_id, :integer

    add_column :matches, :placement, :boolean, null: false, default: false
    add_index :matches, :placement

    add_column :matches, :result, :integer, null: false
    add_index :matches, :result

    add_column :matches, :time_of_day, :integer, null: false
    add_index :matches, :time_of_day

    add_column :matches, :day_of_week, :integer, null: false
    add_index :matches, :day_of_week
  end
end
