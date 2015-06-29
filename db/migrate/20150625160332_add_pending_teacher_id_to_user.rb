# Enabling user to have User.pending_teacher
class AddPendingTeacherIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :pending_teacher_id, :integer
  end
end
