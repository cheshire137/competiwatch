class CreateAccountHeroes < ActiveRecord::Migration[5.1]
  def change
    create_table :account_heroes do |t|
      t.integer :account_id, null: false
      t.integer :hero_id, null: false
      t.integer :seconds_played
      t.timestamps
    end
    add_index :account_heroes, [:account_id, :hero_id], unique: true
    add_index :account_heroes, :hero_id
    add_index :account_heroes, [:account_id, :seconds_played]
  end
end
