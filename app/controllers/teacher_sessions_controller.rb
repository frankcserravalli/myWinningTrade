class TeacherSessionsController < ApplicationController
  before_filter :redirect_signed_in_user, only: [:new, :create]

  skip_before_filter :require_login, :require_iphone_login

  skip_before_filter :require_acceptance_of_terms, if: :current_user

  skip_before_filter :load_portfolio, if: :current_user

  def new
    redirect_to groups_path if current_user
  end

  def create
    user = User.find_by_email(params[:email].downcase)

    # Login user if they are a teacher
    if user && user.authenticate(params[:password]) && user.group == "teacher"
      self.current_user = user

      redirect_to groups_path
    else
      redirect_to '/teacher/sign_in', notice: I18n.t('flash.sessions.create.notice', default: "Invalid email/password combination")
    end
  end

  def sign_up
    if current_user
      teacher = PendingTeacher.find_by_user_id(current_user.id)

      # Has request been made? If so just tell the user the status is pending
      if teacher
        redirect_to groups_path, notice: I18n.t('flash.sessions.create.notice', default: "Your status is pending!")
      else
        # Create a teacher request
        teacher = PendingTeacher.new

        teacher.user_id = current_user.id

        if teacher.save
          redirect_to groups_path, notice: I18n.t('flash.sessions.create.notice', default: "Request Sent!")
        else
          redirect_to groups_path, notice: I18n.t('flash.sessions.create.notice', default: "Oops. Something went wrong!")
        end
      end
    else
      redirect_to signin_path, notice: I18n.t('flash.sessions.create.notice', default: "Please sign in first before you assign yourself as a teacher.")
    end
  end

  def pending
    # Frank's account number is 29
    unless current_user.id.eql? 29
      redirect_to groups_path, notice: I18n.t('flash.sessions.create.notice', default: "You don't have permission to view this page.")
    end

    @teachers_pending = PendingTeacher.all
  end

  def verify
    teacher = PendingTeacher.find_by_user_id(params[:user_id])

    user = User.find(params[:user_id])

    user.group = 'teacher'

    user.save

    teacher.destroy

    redirect_to teacher_pending_path, notice: I18n.t('flash.sessions.create.notice', default: "Teacher added.")
  end

  def remove_pending
    teacher = PendingTeacher.find_by_user_id(params[:user_id])

    teacher.destroy

    redirect_to teacher_pending_path, notice: I18n.t('flash.sessions.create.notice', default: "Non-teacher removed.")
  end

  def destroy
    self.current_user = nil

    redirect_to root_url
  end

  private

  def redirect_signed_in_user
    if current_user
      redirect_to groups_path
    end
  end
end
