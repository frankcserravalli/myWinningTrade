class CreateSubscriptionCustomer < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :user_id
      t.string :payment_option
    end
    add_index :subscription_customers, :user_id
  end

  def self.down
    drop_table :subscription_customer
  end
end
