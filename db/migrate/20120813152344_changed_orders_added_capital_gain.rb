class ChangedOrdersAddedCapitalGain < ActiveRecord::Migration
  def self.up
    add_column :orders, :capital_gain, :decimal, :precision=>10, :scale=>2
  end
  
  def self.down
    remove_column :orders, :capital_gain
  end
end
