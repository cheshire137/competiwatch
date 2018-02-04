class AddBattletagToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :oauth_accounts, :battletag, :string
  end
end
