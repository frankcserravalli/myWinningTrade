class CreateStopLossTransactions < ActiveRecord::Migration
  def self.up
    create_table "stop_loss_transactions", :force => true do |t|
      t.integer  "user_stock_id"
      t.integer  "user_id"
      t.integer  "volume",        :limit => 8
      t.string   "order_type"
      t.string   "status",                     :default => "pending"
      t.string   "measure"
      t.decimal  "price_target"
      t.datetime "executed_at"
      t.datetime "updated_at"
      t.datetime "created_at"
    end

    add_index :stop_loss_transactions, :user_id
    add_index :stop_loss_transactions, :user_stock_id
  end

  def self.down
    drop_table :stop_loss_transactions
  end
end
