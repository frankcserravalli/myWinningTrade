class ChangedUserStocksAddedCostBasis < ActiveRecord::Migration
  def self.up
    add_column :user_stocks, :cost_basis, :string
  end
  
  def self.down
    remove_column :user_stocks, :cost_basis
  end
end
