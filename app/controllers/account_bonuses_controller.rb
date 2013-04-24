class AccountBonusesController < ApplicationController
  def show
  end

  def create
    begin
      # Create the charge on Stripe's servers - this will charge the user's card
      customer = Stripe::Customer.create(
          :card => params[:stripe_card_token],
          :description => current_user.email,
          :plan => params[:bonus_option],
          :email => current_user.email
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

      redirect_to subscriptions_path, notice: I18n.t('flash.users.update.notice', default: params[:stripe_card_token].to_s)
    end
  end
end
