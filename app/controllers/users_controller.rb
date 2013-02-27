class UsersController < ApplicationController

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

  def subscription
    @user = current_user


  end

  def add_subscription

    # Set your secret key: remember to change this to your live secret key in production
    Stripe.api_key = "sk_test_dISm2Qm8RhouxmoU8I6tOEW2 "

    # Get the credit card details submitted by the form
    token = params[:stripeToken]

    begin
      # Create the charge on Stripe's servers - this will charge the user's card
      charge = Stripe::Charge.create(
          :amount => 1000, # amount in cents, again
          :currency => "usd",
          :card => token,
          :description => "payinguser@example.com"
      )
    rescue Stripe::CardError
      redirect_to users_subscription_path, notice: I18n.t('flash.users.update.notice', default: "There is an error. Please try again.")
    rescue Stripe::StripeError
      redirect_to users_subscription_path, notice: I18n.t('flash.users.update.notice', default: "There is an error. Please try again.")
    else
      current_user.upgrade_subscription

      redirect_to users_subscription_path, notice: I18n.t('flash.users.update.notice', default: "Your payment has been processed. Thank you.")
    end


  end

  def update
    #@user = User.find(current_user)

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

end
