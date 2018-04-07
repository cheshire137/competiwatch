class AddPotgToMatches < ActiveRecord::Migration[5.1]
  def change
    add_column :matches, :potg, :boolean
    add_index :matches, :potg
  end
end
