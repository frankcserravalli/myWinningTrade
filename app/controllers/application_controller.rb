class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_login

  protected
  # authentication
  helper_method :current_user
  def current_user
    @current_user ||= User.find_by_id(session[:current_user_id])
  end
  def current_user=(user)
    @current_user = nil
    session[:current_user_id] = user.try(:id)
  end
  def require_login
  	redirect_to login_url, error: I18n.t('flash.sessions.required.error', default: 'Please log in.') unless current_user
  end

end
