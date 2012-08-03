class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :stock_id 
      t.integer :user_id 
      t.decimal :price, :precision=>10, :scale=>2 
      t.integer :volume, :limit=>8 
      t.string :type, :limit=>15 
      t.decimal :value, :precision=>10, :scale=>2 
    end
    add_index :orders, :stock_id
    add_index :orders, :user_id
    add_index :orders, :type
  end
  
  def self.down
    drop_table :orders
  end
end
