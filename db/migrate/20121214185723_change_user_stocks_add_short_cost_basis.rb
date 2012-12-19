class ChangeUserStocksAddShortCostBasis < ActiveRecord::Migration
  def up
    change_table :user_stocks do |t|
      t.decimal "short_cost_basis",                :precision => 10, :scale => 2
    end
  end

  def down
    remove_column :user_stocks, :short_cost_basis
  end
end
