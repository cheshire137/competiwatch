class AddProfileFieldsToOAuthAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :oauth_accounts, :star_url, :text
    add_column :oauth_accounts, :rank, :integer
    add_column :oauth_accounts, :level, :integer
    add_column :oauth_accounts, :level_url, :text
  end
end
