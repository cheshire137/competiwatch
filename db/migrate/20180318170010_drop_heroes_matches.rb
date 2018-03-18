class DropHeroesMatches < ActiveRecord::Migration[5.1]
  def up
    drop_table :heroes_matches
  end

  def down
    create_table "heroes_matches" do |t|
      t.integer "hero_id", null: false
      t.integer "match_id", null: false
      t.index ["hero_id", "match_id"], name: "index_heroes_matches_on_hero_id_and_match_id", unique: true
    end
  end
end
