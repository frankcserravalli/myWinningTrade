class AddPasswordResetToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_reset, :boolean, :default => false
  end
end
