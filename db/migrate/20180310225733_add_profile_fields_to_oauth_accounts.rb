class AddProfileFieldsToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :star_url, :text
    add_column :accounts, :rank, :integer
    add_column :accounts, :level, :integer
    add_column :accounts, :level_url, :text
  end
end
