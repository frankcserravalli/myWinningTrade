class ChangedUsersAddedAccountBalance < ActiveRecord::Migration
  def self.up
    add_column :users, :account_balance, :decimal, :scale=>2, :precision=>10, :default => User::OPENING_BALANCE
  end

  def self.down
    remove_column :users, :account_balance
  end
end
