module TeacherSessionsHelper
  def sign_in(user)
    session[:id] = user.id
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.find_by_id(session[:id])
  end

  def current_user?(user)
    user == current_user
  end

  def sign_out
    self.current_user = nil
    reset_session
  end
end
