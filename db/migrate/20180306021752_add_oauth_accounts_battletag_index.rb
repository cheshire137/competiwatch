class AddAccountsBattletagIndex < ActiveRecord::Migration[5.1]
  def up
    remove_index :accounts, [:provider, :uid]
    add_index :accounts, [:battletag, :provider, :uid], unique: true
  end

  def down
    remove_index :accounts, [:battletag, :provider, :uid]
    add_index :accounts, [:provider, :uid], unique: true
  end
end
