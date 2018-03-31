class AddParentAccountId < ActiveRecord::Migration[5.1]
  class OldUser < ApplicationRecord
    self.table_name = 'users'
  end

  class OldAccount < ApplicationRecord
    self.table_name = 'accounts'
  end

  def up
    add_column :accounts, :parent_account_id, :integer

    OldUser.find_each do |user|
      accounts = OldAccount.where(user_id: user.id)
      if accounts.size > 1
        parent_account = accounts.first
        accounts.drop(1).each do |other_account|
          other_account.parent_account_id = parent_account.id
          other_account.save!
        end
      end
    end

    add_index :accounts, :parent_account_id
  end

  def down
    remove_column :accounts, :parent_account_id
  end
end
