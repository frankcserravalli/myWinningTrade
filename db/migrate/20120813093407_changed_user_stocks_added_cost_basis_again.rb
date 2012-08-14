class ChangedUserStocksAddedCostBasisAgain < ActiveRecord::Migration
  def self.up
    add_column :user_stocks, :cost_basis, :decimal, :precision=>10, :scale=>2
  end

  def self.down
    remove_column :user_stocks, :cost_basis
  end
end
