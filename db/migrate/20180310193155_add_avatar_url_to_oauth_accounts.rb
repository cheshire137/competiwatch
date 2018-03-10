class AddAvatarUrlToOAuthAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :oauth_accounts, :avatar_url, :text
  end
end
