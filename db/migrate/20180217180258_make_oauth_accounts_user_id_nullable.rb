class MakeOAuthAccountsUserIdNullable < ActiveRecord::Migration[5.1]
  def change
    change_column_null :oauth_accounts, :user_id, true
  end
end
