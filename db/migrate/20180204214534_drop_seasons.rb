class DropSeasons < ActiveRecord::Migration[5.1]
  def up
    drop_table :seasons

    remove_column :matches, :season_id

    add_column :matches, :season, :integer, null: false
    add_index :matches, :season
  end

  def down
    create_table :seasons do |t|
      t.string :name, null: false, limit: 30
      t.timestamps
    end
    add_index :seasons, :name, unique: true

    add_column :matches, :season_id, :integer, null: false
    add_index :matches, :season_id
  end
end
