class ChangeUserStocksAddSharesBorrowed < ActiveRecord::Migration
  def up
    change_table :user_stocks do |t|
      t.integer "shares_borrowed", :limit => 8,                                :default => 0
    end
  end

  def down
    remove_column :user_stocks, :shared_borrowed
  end
end
