class UsersController < ApplicationController
=begin
  def profile
    @user = User.find(current_user)

    respond_to do |format|
      format.html # profile.html.erb
    end
  end

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
end
