class ChangedOrdersAddedVolumeRemaining < ActiveRecord::Migration
  def self.up
    add_column :orders, :volume_remaining, :integer, :limit=>8
  end
  
  def self.down
    remove_column :orders, :volume_remaining
  end
end
