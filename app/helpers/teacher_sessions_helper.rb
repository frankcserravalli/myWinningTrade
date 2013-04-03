module TeacherSessionsHelper
  def teacher_sign_in(user)
    session[:teacher_id] = user.id
    self.current_user = user
  end

  def teacher_signed_in?
    !current_user.nil?
  end

  def teacher_current_user=(user)
    @current_user = user
  end

  def teacher_current_user
    @current_user ||= User.find_by_id(session[:teacher_id])
  end

  def teacher_current_user?(user)
    user == current_user
  end

  def teacher_sign_out
    self.current_user = nil
    reset_session
  end
end
