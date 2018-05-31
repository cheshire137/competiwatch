class DropAccountsLevel < ActiveRecord::Migration[5.1]
  def up
    remove_column :accounts, :level
    remove_column :accounts, :level_url
  end

  def down
    add_column :accounts, :level, :integer
    add_column :accounts, :level_url, :text
  end
end
