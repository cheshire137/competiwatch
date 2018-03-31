class AddAccountIdToFriends < ActiveRecord::Migration[5.1]
  class OldFriend < ApplicationRecord
    self.table_name = 'friends'
  end

  class OldAccount < ApplicationRecord
    self.table_name = 'accounts'
  end

  class OldUser < ApplicationRecord
    self.table_name = 'users'
  end

  def up
    add_column :friends, :account_id, :integer

    OldFriend.find_each do |friend|
      user = OldUser.where(id: friend.user_id).first

      if user
        account = OldAccount.where(user_id: user.id).where('parent_account_id IS NULL').first

        if account
          friend.account_id = account.id
          friend.save!
        else
          raise "Could not find account for user #{user.battletag}"
        end
      end
    end

    add_index :friends, [:account_id, :name], unique: true

    remove_column :friends, :user_id
  end

  def down
    add_column :friends, :user_id, :integer

    OldFriend.find_each do |friend|
      account = OldAccount.where(id: friend.account_id).first

      if account
        user = OldUser.where(id: account.user_id).first

        if user
          friend.user_id = user.id
          friend.save!
        else
          raise "Could not find user for account #{account.battletag}"
        end
      end
    end

    add_index :friends, [:user_id, :name], unique: true

    remove_column :friends, :account_id
  end
end
