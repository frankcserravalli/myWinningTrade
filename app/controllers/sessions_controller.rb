class SessionsController < ApplicationController

  def dashboard
    require_login
  end

  def new
    redirect_to root_url and return if current_user
  end

  def create
    self.current_user = User.find_or_create_from_auth_hash(auth_hash)
    if current_user.valid?
      redirect_to root_url, notice: I18n.t('sessions.create.notice')
    else
      redirect_to login_url, error: I18n.t('sessions.create.error')
    end
  end

  def destroy
    self.current_user = nil
    redirect_to login_url, notice: I18n.t('sessions.destroy.notice')
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

end
