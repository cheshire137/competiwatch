class DropMatchTime < ActiveRecord::Migration[5.1]
  def up
    remove_column :matches, :time
    add_index :matches, :oauth_account_id
    add_index :matches, :created_at
  end

  def down
    remove_index :matches, :created_at
    add_column :matches, :time, :datetime
    remove_index :matches, :oauth_account_id
    add_index :matches, [:oauth_account_id, :time]
  end
end
