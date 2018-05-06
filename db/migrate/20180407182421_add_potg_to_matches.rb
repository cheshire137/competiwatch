class AddPotgToMatches < ActiveRecord::Migration[5.1]
  def change
    add_column :matches, :potg, :boolean, default: false, null: false
    add_index :matches, :potg
  end
end
