class ChangedOrdersAddedCostBasis < ActiveRecord::Migration
  def self.up
    add_column :orders, :cost_basis, :decimal, :precision=>10, :scale=>2
  end
  
  def self.down
    remove_column :orders, :cost_basis
  end
end
