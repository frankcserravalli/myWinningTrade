class AddPremiumSubscriptionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :premium_subscription, :boolean, :default => false
  end
end
