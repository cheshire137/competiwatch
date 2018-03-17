class AddHeroIdsToMatches < ActiveRecord::Migration[5.1]
  def up
    add_column :matches, :hero_ids, :integer, array: true, default: [], null: false

    execute <<-SQL
      UPDATE matches SET hero_ids = agg_hero_ids
      FROM (
        SELECT match_id, ARRAY_AGG(hero_id ORDER BY hero_id) AS agg_hero_ids
        FROM heroes_matches
        GROUP BY match_id
      ) AS heroes_matches
      WHERE heroes_matches.match_id = matches.id
    SQL
  end

  def down
    remove_column :matches, :hero_ids
  end
end
