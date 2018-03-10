class MoveAdminToOAuthAccounts < ActiveRecord::Migration[5.1]
  def up
    add_column :oauth_accounts, :admin, :boolean, null: false, default: false
    remove_column :users, :admin
  end

  def down
    add_column :users, :admin, :boolean, default: false, null: false
    execute <<-SQL
      UPDATE users SET admin = oauth_accounts.admin
      FROM (SELECT user_id, admin FROM oauth_accounts) AS oauth_accounts
      WHERE oauth_accounts.user_id = users.id
    SQL
    remove_column :oauth_accounts, :admin
  end
end
