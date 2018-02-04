class AddPriorRankToMatches < ActiveRecord::Migration[5.1]
  def change
    add_column :matches, :prior_rank, :integer
  end
end
