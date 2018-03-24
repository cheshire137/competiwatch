class DropStarUrlFromAccounts < ActiveRecord::Migration[5.1]
  def up
    remove_column :accounts, :star_url
  end

  def down
    add_column :accounts, :star_url, :text
  end
end
