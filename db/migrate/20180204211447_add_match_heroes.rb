class AddMatchHeroes < ActiveRecord::Migration[5.1]
  def change
    create_table :match_heroes do |t|
      t.integer :hero_id, null: false
      t.integer :match_id, null: false
    end
    add_index :match_heroes, [:hero_id, :match_id], unique: true
  end
end
