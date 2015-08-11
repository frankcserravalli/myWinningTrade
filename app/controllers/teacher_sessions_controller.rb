class TeacherSessionsController < Devise::SessionsController

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
    notice = if PendingTeacher.find_by_user_id(signed_user.id)
               I18n.t('flash.sessions.create.notice', default: 'Request Pending!')
             else
               signed_user.create_pending_teacher
               I18n.t('flash.sessions.create.notice', default: 'Request Sent!')
             end
    redirect_to profile_url, notice: notice
  end

  def pending
    pp "#{signed_user.email}, #{Figaro.env.admin}"
    redirect_to groups_url unless signed_user.email == Figaro.env.admin
    @teachers_pending = PendingTeacher.all
  end

  def verify
    User.find(user_id).pending_teacher.upgrade_user_to_teacher
    redirect_to teacher_pending_url, notice: I18n.t(
      'flash.sessions.create.notice', default: 'Teacher added.')
  end

  def remove_pending
    PendingTeacher.find_by_user_id(user_id).destroy
    redirect_to teacher_pending_url, notice: I18n.t(
      'flash.sessions.create.notice', default: 'Non-teacher removed.')
  end

  private

  def user_id
    params.require(:user_id)
  end
end
