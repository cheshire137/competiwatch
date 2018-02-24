class CreateSeasonsAgain < ActiveRecord::Migration[5.1]
  def change
    create_table :seasons do |t|
      t.integer :number, null: false
      t.integer :max_rank, null: false, default: 5000
      t.date :started_on
      t.date :ended_on
    end
    add_index :seasons, :number, unique: true
  end
end
