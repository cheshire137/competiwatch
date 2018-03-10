class AddAvatarUrlToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :avatar_url, :text
  end
end
