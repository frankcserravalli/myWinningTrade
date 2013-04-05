module TeacherSessionsHelper
  def teacher_sign_in(user)
    session[:teacher_id] = user.id
    self.teacher_current_user = user
  end

  def teacher_signed_in?
    !teacher_current_user.nil?
  end

  def teacher_current_user=(user)
    @teacher_current_user = user
  end

  def teacher_current_user
    @teacher_current_user ||= User.find_by_id(session[:teacher_id])
  end

  def teacher_current_user?(user)
    user == teacher_current_user
  end

  def teacher_sign_out
    self.teacher_current_user = nil
    reset_session
  end
end
