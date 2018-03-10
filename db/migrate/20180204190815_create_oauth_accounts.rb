class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.integer :user_id, null: false
      t.string :provider, null: false, limit: 30
      t.string :uid, null: false, limit: 100
      t.timestamps
    end
    add_index :accounts, :user_id
    add_index :accounts, [:provider, :uid], unique: true
  end
end
