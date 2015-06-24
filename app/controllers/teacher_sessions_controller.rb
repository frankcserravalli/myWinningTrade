class TeacherSessionsController < Devise::SessionsController
  before_filter :authenticate_user!, except: [:new, :create]

  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource), notice: I18n.t(
          'flash.sessions.create.notice',
          default: 'Please request a teacher status.')
  end

  def request_upgrade
    if current_user
      teacher = PendingTeacher.find_by_user_id(current_user.id)

      # Has request been made? If so just tell the user the status is pending
      if teacher
        redirect_to profile_url, notice: I18n.t('flash.sessions.create.notice', default: "Your status is pending!")
      else
        # Create a teacher request
        teacher = PendingTeacher.new

        teacher.user_id = current_user.id

        if teacher.save
          redirect_to profile_url, notice: I18n.t('flash.sessions.create.notice', default: "Request Sent!")
        else
          redirect_to profile_url, notice: I18n.t('flash.sessions.create.notice', default: "Oops. Something went wrong!")
        end
      end
    else
      redirect_to teacher_sign_in_url, notice: I18n.t('flash.sessions.create.notice', default: "Please sign in first before you assign yourself as a teacher.")
    end
  end

  def pending
    # Frank's account number is 29
    unless current_user.id.eql? 29
      redirect_to groups_url, notice: I18n.t('flash.sessions.create.notice', default: "You don't have permission to view this page.")
    end

    @teachers_pending = PendingTeacher.all
  end

  def verify
    PendingTeacher.upgrade_user_to_teacher(params[:user_id])
    redirect_to teacher_pending_url, notice: I18n.t('flash.sessions.create.notice', default: "Teacher added.")
  end

  def remove_pending
    teacher = PendingTeacher.find_by_user_id(params[:user_id]).destroy
    redirect_to teacher_pending_url, notice: I18n.t('flash.sessions.create.notice', default: "Non-teacher removed.")
  end

  def destroy
    self.current_user = nil
    redirect_to root_url
  end

  private

  def redirect_signed_in_teacher
    if current_user and current_user.group == "teacher"
      redirect_to groups_url
    end
  end
end
