class OldUser < ApplicationRecord
  self.table_name = 'users'
end

class OldAccount < ApplicationRecord
  self.table_name = 'accounts'
end

class AddParentAccountId < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :parent_account_id, :integer

    OldUser.find_each do |user|
      accounts = OldAccount.where(user_id: user.id)
      if accounts.size > 1
        parent_account = accounts.first
        accounts.drop(1).each do |other_account|
          other_account.parent_account_id = parent_account.id
          other_account.save!
        end
      elsif accounts.size == 1
        sole_account = accounts.first
        sole_account.user_id = nil
        sole_account.save!
      else
        user.destroy!
      end
    end

    add_index :accounts, :parent_account_id
  end
end
