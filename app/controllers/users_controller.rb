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
    customer = SubscriptionCustomer.find_by_user_id(params[:user_id])

    if customer and customer.delete
      current_user.cancel_subscription

      redirect_to users_subscription_path, notice: I18n.t('flash.users.update.notice', default: "Subscription cancelled")
    else
      redirect_to users_subscription_path, notice: I18n.t('flash.users.update.notice', default: "Subscription cannot be cancelled. Please contact the website.")
    end
  end

  def add_subscription
    begin
      # Create the charge on Stripe's servers - this will charge the user's card
      customer = Stripe::Customer.create(
          :card => params[:stripe_card_token],
          :description => current_user.email,
          :plan => params[:payment_plan]
      )

      # Add Subscription Customer into DB
      SubscriptionCustomer.add_customer(current_user.id, customer.id, params[:payment_plan])
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
    rescue Exception
      # Rescue any exception

      redirect_to users_subscription_path, notice: I18n.t('flash.users.update.notice', default: "Problem with subscribing.")
    else
      current_user.upgrade_subscription

      redirect_to users_subscription_path, notice: I18n.t('flash.users.update.notice', default: "Thanks for subscribing!")
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

end
