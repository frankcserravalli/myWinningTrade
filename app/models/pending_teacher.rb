class PendingTeacher < ActiveRecord::Base
  attr_accessible :user_id

  belongs_to :user

  def self.upgrade_user_to_teacher(user_id)
    teacher = PendingTeacher.find_by_user_id(user_id)

    user = User.find(user_id)

    user.group = 'teacher'

    user.save

    teacher.destroy
  end
end
