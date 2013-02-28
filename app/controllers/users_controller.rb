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

  def delete_subscription

  end

  def add_subscription
   # Get the credit card details submitted by the form
    token = params[:stripe_card_token]

    begin
      # Create the charge on Stripe's servers - this will charge the user's card
      customer = Stripe::Customer.create(
          :card => token,
          :description => "payinguser@example.com",
          :plan => params[:payment_plan]
      )
    rescue Stripe::CardError => e
      # Card error

      redirect_to users_subscription_path, notice: I18n.t('flash.users.update.notice', default: e.to_s)
    rescue Stripe::StripeError => e
      # General error with Stripe

      redirect_to users_subscription_path, notice: I18n.t('flash.users.update.notice', default: e.to_s)
    rescue Stripe::InvalidRequestError => e
      # Invalid parameters were supplied to Stripe's API

      redirect_to users_subscription_path, notice: I18n.t('flash.users.update.notice', default: e.to_s)
    rescue Stripe::AuthenticationError => e
      # Authentication with Stripe's API failed
      # (maybe you changed API keys recently)

      redirect_to users_subscription_path, notice: I18n.t('flash.users.update.notice', default: e.to_s)
    rescue Stripe::APIConnectionError => e
      # Network communication with Stripe failed

      redirect_to users_subscription_path, notice: I18n.t('flash.users.update.notice', default: e.to_s)
    else
      current_user.upgrade_subscription

      # Add Subscription Customer here



      redirect_to users_subscription_path, notice: I18n.t('flash.users.update.notice', default: customer.to_s)
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
