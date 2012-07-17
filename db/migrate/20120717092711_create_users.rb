class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email 
      t.string :name 
      t.string :provider, :limit=>16 
      t.string :uid 
    end
    add_index :users, :provider
    add_index :users, :uid
  end
  
  def self.down
    drop_table :users
  end
end
