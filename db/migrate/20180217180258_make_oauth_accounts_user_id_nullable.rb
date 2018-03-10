class MakeAccountsUserIdNullable < ActiveRecord::Migration[5.1]
  def change
    change_column_null :accounts, :user_id, true
  end
end
