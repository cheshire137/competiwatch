class AddMatchTime < ActiveRecord::Migration[5.1]
  def change
    add_column :matches, :time, :datetime, null: false
    remove_index :matches, :account_id
    add_index :matches, [:account_id, :time]
  end
end
