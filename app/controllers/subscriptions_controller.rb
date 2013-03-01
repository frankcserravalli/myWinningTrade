class SubscriptionsController < ApplicationController


  def show
    @user = current_user
  end

  def create
    begin
      # Create the charge on Stripe's servers - this will charge the user's card
      customer = Stripe::Customer.create(
          :card => params[:stripe_card_token],
          :description => current_user.email,
          :plan => params[:payment_plan]
      )

      # Add Subscription Customer into DB
      Subscription.add_customer(current_user.id, customer.id, params[:payment_plan])
    rescue Stripe::CardError => e
      # Card error

      redirect_to subscriptions_path, notice: I18n.t('flash.users.update.notice', default: e.to_s)
    rescue Stripe::StripeError => e
      # General error with Stripe

      redirect_to subscriptions_path, notice: I18n.t('flash.users.update.notice', default: e.to_s)
    rescue Stripe::InvalidRequestError => e
      # Invalid parameters were supplied to Stripe's API

      redirect_to subscriptions_path, notice: I18n.t('flash.users.update.notice', default: e.to_s)
    rescue Stripe::AuthenticationError => e
      # Authentication with Stripe's API failed
      # (maybe you changed API keys recently)

      redirect_to subscriptions_path, notice: I18n.t('flash.users.update.notice', default: e.to_s)
    rescue Stripe::APIConnectionError => e
      # Network communication with Stripe failed

      redirect_to subscriptions_path, notice: I18n.t('flash.users.update.notice', default: e.to_s)
    rescue Exception
      # Rescue any exception

      redirect_to subscriptions_path, notice: I18n.t('flash.users.update.notice', default: "Problem with subscribing.")
    else
      current_user.upgrade_subscription

      redirect_to subscriptions_path, notice: I18n.t('flash.users.update.notice', default: "Thanks for subscribing!")
    end
  end

  def destroy
    customer = Subscription.find_by_user_id(params[:user_id])

    if customer and customer.delete
      current_user.cancel_subscription

      redirect_to subscriptions_path, notice: I18n.t('flash.users.update.notice', default: "Subscription cancelled.")
    else
      redirect_to subscriptions_path, notice: I18n.t('flash.users.update.notice', default: "Subscription cannot be cancelled. Please contact the website.")
    end
  end
end

def update
  @subscription = Subscription.find(params[:id])

  respond_to do |format|
    if @subscription.update_attributes(params[:subscription])
      format.html { redirect_to @subscription, notice: 'Subscription was successfully updated.' }
      format.json { head :no_content }
    else
      format.html { render action: "edit" }
      format.json { render json: @subscription.errors, status: :unprocessable_entity }
    end
  end
end

