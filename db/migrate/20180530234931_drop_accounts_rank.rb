class DropAccountsRank < ActiveRecord::Migration[5.1]
  def up
    remove_column :accounts, :rank
  end

  def down
    add_column :accounts, :rank, :integer
  end
end
