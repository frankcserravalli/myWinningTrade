class SessionsController < ApplicationController
  skip_before_filter :require_login, except: :destroy
  skip_before_filter :require_acceptance_of_terms
  skip_before_filter :load_portfolio


  def new
    flash[:notice] = "Sorry, there is an error. Please try again." if params[:message]

    redirect_to root_url and return if current_user
  end

  def create

    if params[:email]
      # If user is coming from sign in page for MWT
      user = User.find_by_email(params[:email]).authenticate(params[:password])

      if user
        # User exists so we assign them to current user
        self.current_user = user

        redirect_to root_url, notice: I18n.t('flash.sessions.create.notice', default: 'You have been logged in.')
      else
        redirect_to signin_url, alert: I18n.t('flash.sessions.create.alert', default: 'Your email/password did not match.')
      end

    else
      # We are assuming the user has come from the authentication system from an social network
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
