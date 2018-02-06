class MakeRankNullable < ActiveRecord::Migration[5.1]
  def change
    change_column_null :matches, :rank, true
  end
end
