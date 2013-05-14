class UsersController < ApplicationController
  def profile
    @user = User.find(current_user)
  end
=begin

  def edit
    @user = current_user

    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  def update
    #@user = User.find(current_user.id)

    respond_to do |format|
      if current_user.update_attributes(params[:user])
        format.html do
          redirect_to profile_path, notice: I18n.t('flash.users.update.notice', default: 'Profile successfully updated.')
        end
      else
        format.html do
          redirect_to profile_path, notice: I18n.t('flash.users.update.notice', default: 'Profile did not update!')
        end
     end
    end

  end
=end
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

  end

  def sign_in

  end

end
