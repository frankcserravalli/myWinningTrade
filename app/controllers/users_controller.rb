class UsersController < ApplicationController

  def profile
    @user = signed_user
  end

  def edit
    @user = signed_user
  end

  def update
    if signed_user.update_attributes(user_attributes)
      signed_user.save
      # Set the password_reset field to true
      # signed_user.update(password_reset: true)
      # check if they requested for a teacher status,
      # and if so request a pending teacher record
      PendingTeacher.create(user_id: signed_user.id) if params['teacher_request']
      redirect_to profile_url, notice: I18n.t('flash.users.update.notice', default: 'Profile successfully updated.')
    else
      render 'edit'
      # redirect_to profile_url, notice: I18n.t('flash.users.update.notice', default: 'Unable to update profile')
    end
  end

  def trading_analysis_pdf
    content = signed_user.create_trading_analysis_pdf
    kit = PDFKit.new(content, page_size: 'Letter')
    kit.stylesheets << 'app/assets/stylesheets/pdf/pdf.css'
    kit.stylesheets << 'app/assets/stylesheets/pdf/bootstrap.min.css'
    output = kit.to_pdf
    respond_to do |format|
      format.pdf do
        send_data output, filename: 'trading_analysis.pdf', type: 'application/pdf'
      end
    end
  end

  private

  def user_attributes
    params.require(:user).permit(
      :name, :password, :password_confirmation,
      :email, :provider, :uid, :teacher_request)
  end

  def teacher_request
    params.permit(:teacher_request)
  end
end
