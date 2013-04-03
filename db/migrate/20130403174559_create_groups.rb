class CreateGroups < ActiveRecord::Migration
  def change
    create_table :group do |t|
      t.integer :user_id
      t.string :name

      t.timestamps
    end
  end
end
