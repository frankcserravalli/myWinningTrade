class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.integer :customer_id
      t.string :payment_plan

      t.timestamps
    end
    add_index :subscriptions, :user_id
  end
end
