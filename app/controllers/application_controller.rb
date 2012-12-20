class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_login
  before_filter :require_acceptance_of_terms, if: :current_user

 # authentication
  helper_method :current_user
  def current_user
    @current_user ||= User.find_by_id(session[:current_user_id])
  end
  def current_user=(user)
    @current_user = nil
    session[:current_user_id] = user.try(:id)
  end
  def require_login
  	redirect_to login_url, error: I18n.t('flash.sessions.required.error', default: 'Please log in.') unless current_user
  end

  # authorization
  def require_acceptance_of_terms
    redirect_to terms_path and return unless current_user && current_user.accepted_terms?
  end

  before_filter :load_portfolio, if: :current_user
  def load_portfolio
    @portfolio = {}.tap do |p|
      user_stocks = current_user.user_stocks.includes(:stock).with_shares_owned
      user_shorts = current_user.user_stocks.includes(:stock).with_shares_borrowed
      stock_symbols = user_stocks.map { |s| s.stock.symbol }
      stock_details = Finance.stock_details_for_list(stock_symbols)
      short_symbols = user_shorts.map { |s| s.stock.symbol }
      short_details = Finance.stock_details_for_list(short_symbols)

      p[:current_value] = 0
      p[:purchase_value] = 0
      p[:stocks] = {}
      p[:shorts] = {}

      user_stocks.each do |user_stock|
        stock_symbol = user_stock.stock.symbol
        details = stock_details[stock_symbol]
        purchase_value = user_stock.cost_basis.to_f * user_stock.shares_owned.to_f
        current_price = details.current_price.to_f
        current_value = current_price * user_stock.shares_owned.to_f
        shares_owned = user_stock.shares_owned
        cost_basis = user_stock.cost_basis.to_f
        p[:stocks][stock_symbol] = {
          name: user_stock.stock.name,
          current_price: current_price,
          shares_owned: shares_owned,
          current_value: current_value,
          cost_basis: cost_basis,
          capital_gain: current_price - cost_basis,
          percent_gain: ((current_price - cost_basis) * 100 / cost_basis).round(1)
        }
        p[:current_value] += current_value
        p[:purchase_value] += purchase_value
      end

      user_shorts.each do |user_stock|
        Rails.logger.info(user_stock.stock.symbol)
        stock_symbol = user_stock.stock.symbol
        details = short_details[stock_symbol]
        purchase_value = user_stock.short_cost_basis.to_f * user_stock.shares_borrowed.to_f
        current_price = details.current_price.to_f
        current_value = current_price * user_stock.shares_borrowed.to_f
        shares_borrowed = user_stock.shares_borrowed
        short_cost_basis = user_stock.short_cost_basis.to_f
        p[:shorts][stock_symbol] = {
          name: user_stock.stock.name,
          current_price: current_price,
          shares_owned: shares_borrowed,
          current_value: current_value,
          cost_basis: short_cost_basis,
          capital_gain: current_price - short_cost_basis,
          percent_gain: (-(current_price - short_cost_basis) * 100 / short_cost_basis).round(1)
        }
        p[:current_value] += current_value
        p[:purchase_value] += purchase_value
      end

      if p[:purchase_value].to_f == 0.0
        p[:percent_gain] = 0.0
      else
        p[:percent_gain] = ((p[:current_value] - p[:purchase_value]) * 100 / p[:purchase_value]).round(1)
      end
    end

  end

end
