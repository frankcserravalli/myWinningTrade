class CreateDateTimeTransactions < ActiveRecord::Migration
  def self.up
    create_table "date_time_transactions", :force => false do |t|
      t.integer  "user_stock_id"
      t.integer  "user_id"
      t.integer  "volume",        :limit => 8
      t.string   "order_type"
      t.string   "status",                     :default => "pending"
      t.datetime "execute_at"
      t.datetime "updated_at"
      t.datetime "created_at"
    end

    add_index :date_time_transactions, :user_id
    add_index :date_time_transactions, :user_stock_id
  end

  def self.down
    drop_table :date_time_transactions
  end
end
