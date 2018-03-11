class RenameAccounts < ActiveRecord::Migration[5.1]
  def up
    rename_table :oauth_accounts, :accounts
    rename_column :matches, :oauth_account_id, :account_id
    rename_column :season_shares, :oauth_account_id, :account_id
    rename_column :users, :default_oauth_account_id, :default_account_id
  end

  def down
    rename_column :users, :default_account_id, :default_oauth_account_id
    rename_column :season_shares, :account_id, :oauth_account_id
    rename_column :matches, :account_id, :oauth_account_id
    rename_table :accounts, :oauth_accounts
  end
end
