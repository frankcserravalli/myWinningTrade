class ChangedOrdersAddedUserStockIdAndDeletedStockId < ActiveRecord::Migration
  def self.up
    add_column :orders, :user_stock_id, :integer
    remove_column :orders, :stock_id
    add_index :orders, :user_stock_id
  end
  
  def self.down
    add_column :orders, :stock_id, :integer, :limit=>nil
    remove_column :orders, :user_stock_id
  end
end
