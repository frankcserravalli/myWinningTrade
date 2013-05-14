class SessionsController < ApplicationController
  skip_before_filter :require_login, except: :destroy
  skip_before_filter :require_acceptance_of_terms

  def new
    redirect_to root_url and return if current_user
  end

  def create
    # If user is coming from sign in page for MWT
    if params[:user]
      @user = User.find_by_email(params[:user][:email])

      if @user
        # User exists so we assign them to current user
        self.current_user = @user

        redirect_to root_url, notice: I18n.t('flash.sessions.create.notice', default: 'You have been logged in.')

      else

        redirect_to login_url, alert: I18n.t('flash.sessions.create.alert', default: 'Could not authenticate :(')

      end

    else
      self.current_user = User.find_or_create_from_auth_hash(auth_hash)
      if current_user.valid?
        redirect_to root_url, notice: I18n.t('flash.sessions.create.notice', default: 'You have been logged in.')
      else
        redirect_to login_url, alert: I18n.t('flash.sessions.create.alert', default: 'Could not authenticate :(')
      end
    end

  end

  def destroy
    self.current_user = nil
    redirect_to login_url, notice: I18n.t('flash.sessions.destroy.notice', default: 'You have been logged out.')
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

end
