class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_login

  protected
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

  before_filter :load_portfolio, if: :current_user
  def load_portfolio
    @portfolio = {}.tap do |p|
      user_stocks = current_user.user_stocks.includes(:stock)
      stock_symbols = user_stocks.map { |s| s.stock.symbol }
      stock_details = Finance.stock_details_for_list(stock_symbols)

      stock_details.each do |stock_symbol, details|
      end

      # user_stock.current_value = shares_owned * current (bid?)
      # user_stock.cost_basis
      # portfolio.total_value = sum(user_stock.total_value)

      # how to deal with multiple purchases of the same stock?
      # --------------
      # user_stock: cost_basis (purchase_price + fee) / num_stocks
      # user_stock: net capital gain/loss [current_value - cost_basis]

    end

  end

end

# add cost_basis to 'buy'
# on buy/sell: update cache cost_basis
