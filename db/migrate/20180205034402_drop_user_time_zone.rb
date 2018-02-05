class DropUserTimeZone < ActiveRecord::Migration[5.1]
  def up
    remove_column :users, :time_zone
  end

  def down
    add_column :users, :time_zone, :string, null: false, default: 'UTC'
  end
end
