class AddDefaultOauthAccountIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :default_oauth_account_id, :integer

    execute <<-SQL
      UPDATE users SET default_oauth_account_id = oauth_accounts.id
      FROM (SELECT id, user_id FROM oauth_accounts) AS oauth_accounts
      WHERE oauth_accounts.user_id = users.id
    SQL

    add_index :users, :default_oauth_account_id
  end
end
