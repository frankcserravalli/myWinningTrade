class CreatePendingTeachers < ActiveRecord::Migration
  def change
    create_table :pending_teachers do |t|
      t.integer :user_id

      t.timestamps
    end
  end
end
