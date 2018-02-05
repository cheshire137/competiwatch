class RenameJoinTable < ActiveRecord::Migration[5.1]
  def up
    rename_table :match_heroes, :heroes_matches
  end

  def down
    rename_table :heroes_matches, :match_heroes
  end
end
