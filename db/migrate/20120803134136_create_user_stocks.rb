class CreateUserStocks < ActiveRecord::Migration
  def self.up
    create_table :user_stocks do |t|
      t.integer :user_id 
      t.integer :stock_id 
      t.integer :shares_owned, :default=>0, :limit=>8 
    end
    add_index :user_stocks, :user_id
    add_index :user_stocks, :stock_id
  end
  
  def self.down
    drop_table :user_stocks
  end
end
