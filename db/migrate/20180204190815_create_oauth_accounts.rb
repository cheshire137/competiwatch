class CreateOauthAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :oauth_accounts do |t|
      t.integer :user_id, null: false
      t.string :provider, null: false, limit: 30
      t.string :uid, null: false, limit: 100
      t.timestamps
    end
    add_index :oauth_accounts, :user_id
    add_index :oauth_accounts, [:provider, :uid], unique: true
  end
end
