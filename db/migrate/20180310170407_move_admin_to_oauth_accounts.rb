class MoveAdminToAccounts < ActiveRecord::Migration[5.1]
  def up
    add_column :accounts, :admin, :boolean, null: false, default: false
    remove_column :users, :admin
  end

  def down
    add_column :users, :admin, :boolean, default: false, null: false
    execute <<-SQL
      UPDATE users SET admin = accounts.admin
      FROM (SELECT user_id, admin FROM accounts) AS accounts
      WHERE accounts.user_id = users.id
    SQL
    remove_column :accounts, :admin
  end
end
