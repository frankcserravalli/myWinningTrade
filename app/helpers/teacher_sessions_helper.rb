module TeacherSessionsHelper
  def teacher_sign_in(user)
    session[:teacher_id] = user.id
    self.teacher_signed_user = user
  end

  def teacher_signed_in?
    !teacher_signed_user.nil?
  end

  def teacher_signed_user=(user)
    @teacher_signed_user = user
  end

  def teacher_signed_user
    @teacher_signed_user ||= User.find_by_id(session[:teacher_id])
  end

  def teacher_signed_user?(user)
    user == teacher_signed_user
  end

  def teacher_sign_out
    self.teacher_signed_user = nil
    reset_session
  end
end
