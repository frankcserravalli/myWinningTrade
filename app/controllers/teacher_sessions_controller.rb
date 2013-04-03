class TeacherSessionsController < ApplicationController
  before_filter :redirect_signed_in_user, only: [:new, :create]

  skip_before_filter :require_login, :require_iphone_login

  skip_before_filter :require_acceptance_of_terms, if: :current_user

  skip_before_filter :load_portfolio, if: :current_user

  def new

  end

  def create
    user = User.find_by_email(params[:email].downcase)

    if user && user.authenticate(params[:password]) && user.group.eql?("teacher")
      teacher_sign_in user

      redirect_to groups_path
    else
      #flash.now[:error] = "Invalid email/password combination"

      render 'new', notice: I18n.t('flash.sessions.create.notice', default: "Invalid email/password combination")


    end
  end

  def destroy
    teacher_sign_out

    redirect_to root_url
  end

  private

  def redirect_signed_in_user
    if teacher_signed_in?
      redirect_to groups_path
    end
  end
end
