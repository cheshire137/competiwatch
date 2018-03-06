class AddOAuthAccountsBattletagIndex < ActiveRecord::Migration[5.1]
  def up
    remove_index :oauth_accounts, [:provider, :uid]
    add_index :oauth_accounts, [:battletag, :provider, :uid], unique: true
  end

  def down
    remove_index :oauth_accounts, [:battletag, :provider, :uid]
    add_index :oauth_accounts, [:provider, :uid], unique: true
  end
end
