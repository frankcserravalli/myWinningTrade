class UsersController < ApplicationController

  skip_before_filter :require_login, only: [:sign_up, :sign_in, :create]

  def profile
    @user = User.find(current_user)
  end

  def create
    puts params
    
    if params[:user][:email].blank?
      redirect_to signup_path, notice: I18n.t('flash.users.update.notice', default: 'Please fill a valid email and/or password.')
    else

      # Set the provider and uid to mwt, will change when user connects account to social network
      params[:user][:provider] = "mwt"
      params[:user][:uid] = "nil"

      # Set the params to a new user
      user = User.new(params[:user])

      if user.save

        # Since the user was saved, we can now go ahead and check if they requested for a teacher status,
        # and if so request a pending teacher record
        #puts params[:teacher_request]

        if params[:teacher_request] == "1"
          teacher_pending = TeacherPending.new

          teacher_pending.user_id = user.id

          teacher_pending.save
        end

        redirect_to signin_path, notice: I18n.t('flash.users.update.notice', default: 'Your account is created. Please Sign In Now.')
      else
        redirect_to signup_path, notice: I18n.t('flash.users.update.notice', default: 'Unable to create your account. Please try again.')
      end
    end
  end

  def edit
    @user = current_user
  end

  def update
    if current_user.update_attributes(params[:user])
      redirect_to profile_path, notice: I18n.t('flash.users.update.notice', default: 'Profile successfully updated.')
    else
      redirect_to profile_path, notice: I18n.t('flash.users.update.notice', default: 'Profile did not update!')
    end
  end

  def trading_analysis_pdf
    content = current_user.create_trading_analysis_pdf

    kit = PDFKit.new(content, :page_size => 'Letter')

    kit.stylesheets << 'app/assets/stylesheets/pdf/pdf.css'

    kit.stylesheets << 'app/assets/stylesheets/pdf/bootstrap.min.css'

    output = kit.to_pdf

    respond_to do |format|
      format.pdf do
        send_data output, :filename => "trading_analysis.pdf",
                  :type => "application/pdf"
      end
    end
  end

  def test

  end

  def sign_up
    @user = User.new
  end

  def sign_in

  end


end
