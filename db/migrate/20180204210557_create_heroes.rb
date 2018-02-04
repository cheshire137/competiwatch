class CreateHeroes < ActiveRecord::Migration[5.1]
  def change
    create_table :heroes do |t|
      t.string :name, null: false, limit: 30
      t.string :role, null: false, limit: 20
      t.timestamps
    end
    add_index :heroes, :name, unique: true
    add_index :heroes, :role
  end
end
