class AddSlugToMaps < ActiveRecord::Migration[5.1]
  def change
    add_column :maps, :slug, :string
  end
end
