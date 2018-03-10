class RenameAccounts < ActiveRecord::Migration[5.1]
  def up
    rename_table :accounts, :accounts
    rename_column :matches, :account_id, :account_id
    rename_column :season_shares, :account_id, :account_id
    rename_column :users, :default_account_id, :default_account_id
  end

  def down
    rename_column :users, :default_account_id, :default_account_id
    rename_column :season_shares, :account_id, :account_id
    rename_column :matches, :account_id, :account_id
    rename_table :accounts, :accounts
  end
end
