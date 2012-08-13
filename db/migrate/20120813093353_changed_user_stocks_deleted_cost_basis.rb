class ChangedUserStocksDeletedCostBasis < ActiveRecord::Migration
  def self.up
    remove_column :user_stocks, :cost_basis
  end
  
  def self.down
    add_column :user_stocks, :cost_basis, :string, :limit=>255
  end
end
