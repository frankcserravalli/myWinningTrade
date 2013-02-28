class CreateSubscriptionCustomers < ActiveRecord::Migration
  def change
    create_table :subscription_customers do |t|
      t.integer :user_id
      t.string :payment_plan

      t.timestamps
    end
    add_index :subscription_customers, :user_id
  end
end
