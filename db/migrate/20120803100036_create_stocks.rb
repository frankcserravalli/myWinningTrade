class CreateStocks < ActiveRecord::Migration
  def self.up
    create_table :stocks do |t|
      t.string :name 
      t.string :symbol, :limit=>7 
    end
  end
  
  def self.down
    drop_table :stocks
  end
end
