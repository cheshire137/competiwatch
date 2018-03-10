class AddDefaultAccountIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :default_account_id, :integer

    execute <<-SQL
      UPDATE users SET default_account_id = accounts.id
      FROM (SELECT id, user_id FROM accounts) AS accounts
      WHERE accounts.user_id = users.id
    SQL

    add_index :users, :default_account_id
  end
end
