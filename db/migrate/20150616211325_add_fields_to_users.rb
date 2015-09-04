class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :account_balance, :decimal, default: 50000.0
    add_column :users, :accepted_terms, :boolean
    add_column :users, :premium, :boolean
    add_column :users, :premium_subscription, :boolean, default: false
    add_column :users, :group, :string, default: 'student'
  end
end
