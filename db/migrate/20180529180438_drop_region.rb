class DropRegion < ActiveRecord::Migration[5.1]
  def up
    remove_column :accounts, :region
  end

  def down
    add_column :accounts, :region, :string, limit: 6, default: 'us', null: false
  end
end
