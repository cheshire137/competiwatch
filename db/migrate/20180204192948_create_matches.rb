class CreateMatches < ActiveRecord::Migration[5.1]
  def change
    create_table :matches do |t|
      t.integer :oauth_account_id, null: false
      t.integer :map_id, null: false
      t.integer :rank, null: false
      t.text :comment
      t.timestamps
    end
    add_index :matches, :oauth_account_id
    add_index :matches, :map_id
  end
end
