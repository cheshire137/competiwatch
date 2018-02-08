class AddColorToMaps < ActiveRecord::Migration[5.1]
  def change
    add_column :maps, :color, :string, limit: 16, null: false, default: '#ffffff'
  end
end
