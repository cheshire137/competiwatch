class AddThrowerLeaverToMatches < ActiveRecord::Migration[5.1]
  def change
    add_column :matches, :enemy_thrower, :boolean
    add_index :matches, :enemy_thrower

    add_column :matches, :ally_thrower, :boolean
    add_index :matches, :ally_thrower

    add_column :matches, :enemy_leaver, :boolean
    add_index :matches, :enemy_leaver

    add_column :matches, :ally_leaver, :boolean
    add_index :matches, :ally_leaver
  end
end
