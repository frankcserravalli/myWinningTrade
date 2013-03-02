class SubscriptionsController < ApplicationController

  def show
    @subscription = Subscription.find_by_user_id(current_user.id)
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

      redirect_to subscriptions_path, notice: I18n.t('flash.users.update.notice', default: e.to_s)
    else
      current_user.upgrade_subscription

      redirect_to subscriptions_path, notice: I18n.t('flash.users.update.notice', default: customer.id.to_s)
    end
  end

  def destroy
    customer = Subscription.find_by_user_id(params[:user_id])

    the_customer = Stripe::Customer.retrieve(customer.customer_id)

    if customer and customer.delete and the_customer.cancel_subscription
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


#<Stripe::Customer:0x3fc8aa23785c>
#JSON: {"id":"cus_1NrFFUjI9tqSAc","object":"customer","created":1362191889,"livemode":false,"description":null,"active_card":{"object":"card","last4":"4242","type":"Visa","exp_month":1,"exp_year":2015,"fingerprint":"jFOEeG9Y0bMNWBnI","country":"US","name":null,"address_line1":null,"address_line2":null,"address_city":null,"address_state":null,"address_zip":null,"address_country":null,"cvc_check":"pass","address_line1_check":null,"address_zip_check":null},"email":null,"delinquent":false,"subscription":{"plan":{"id":"six","interval":"month","name":"six","amount":1500,"currency":"usd","object":"plan","livemode":false,"interval_count":6,
