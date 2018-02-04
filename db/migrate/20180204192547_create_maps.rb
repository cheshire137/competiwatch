class CreateMaps < ActiveRecord::Migration[5.1]
  def change
    create_table :maps do |t|
      t.string :name, limit: 50, null: false
      t.string :map_type, limit: 30, null: false
      t.timestamps
    end
    add_index :maps, :name, unique: true
  end
end
