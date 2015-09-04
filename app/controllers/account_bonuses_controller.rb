class AccountBonusesController < ApplicationController
  include AccountBonusHelper

  def show
  end

  def create
    begin
      # Create the charge on Stripe's servers - this will charge the user's card

      # Select the bonus option and convert it to the bonus payment amount
      bonus_payment = convert_option_to_amount(params[:bonus_option])

      charge = Stripe::Charge.create(
        :amount => bonus_payment, # amount in cents
        :currency => "usd",
        :card => params[:stripe_card_token],
        :description => "Account bonus payment"
      )

      # Add Subscription Customer into DB
    rescue Stripe::CardError => e
      # Card error

      redirect_to account_bonuses_path, notice: I18n.t('flash.users.update.notice', default: e.to_s)
    rescue Stripe::StripeError => e
      # General error with Stripe

      redirect_to account_bonuses_path, notice: I18n.t('flash.users.update.notice', default: e.to_s)
    rescue Stripe::InvalidRequestError => e
      # Invalid parameters were supplied to Stripe's API

      redirect_to account_bonuses_path, notice: I18n.t('flash.users.update.notice', default: e.to_s)
    rescue Stripe::AuthenticationError => e
      # Authentication with Stripe's API failed
      # (maybe you changed API keys recently)

      redirect_to account_bonuses_path, notice: I18n.t('flash.users.update.notice', default: e.to_s)
    rescue Stripe::APIConnectionError => e
      # Network communication with Stripe failed

      redirect_to account_bonuses_path, notice: I18n.t('flash.users.update.notice', default: e.to_s)
    rescue Exception
      # Rescue any exception

      redirect_to account_bonuses_path, notice: I18n.t('flash.users.update.notice', default: e.to_s)
    else
      signed_user.add_capital_to_account(params[:bonus_option])

      redirect_to profile_path, notice: I18n.t('flash.users.update.notice', default: "Account bonus added!")
    end
  end
end
