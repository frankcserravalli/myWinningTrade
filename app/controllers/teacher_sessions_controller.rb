class TeacherSessionsController < ApplicationController
  include TeacherSessionsHelper

  before_filter :redirect_signed_in_user, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by_email(params[:session][:email].downcase)

    if user && user.authenticate(params[:session][:password]) && user.group.eql?("teacher")
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
