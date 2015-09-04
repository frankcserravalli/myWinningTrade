# Overwriting devise registrations controller
class RegistrationsController < Devise::RegistrationsController

  def create
    @user = signed_user
    if @user.guest
      @user.update_attributes(sign_up_params)
      @user.guest = false
      @user.save
      sign_in_and_redirect @user
    else
      super
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(
      :name, :email, :password, :password_confirmation)
  end
end
