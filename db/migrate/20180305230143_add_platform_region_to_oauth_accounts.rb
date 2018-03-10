class AddPlatformRegionToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :platform, :string, limit: 3, default: 'pc', null: false
    add_column :accounts, :region, :string, limit: 6, default: 'us', null: false
  end
end
