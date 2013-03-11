include ActionView::Helpers::DateHelper
class ApplicationController < ActionController::Base
  protect_from_forgery
  include UsersHelper
  before_filter :require_login
  before_filter :require_iphone_login
  before_filter :require_acceptance_of_terms, if: :current_user
  before_filter :load_portfolio, if: :current_user

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

  def require_acceptance_of_terms
    redirect_to terms_path and return unless current_user && current_user.accepted_terms?
  end

  # api authentication
  def valid_user_id
    @user = User.find_by_id(params[:user_id])
    return @user if @user
    respond_with "Invalid user"
  end

  # inside buys, sells, shortsellborrows controllers
  def when_to_execute_order(type)
    @stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound
    @order_type = type.capitalize
    @order_type = "ShortSellBorrow" if @order_type == "Short_sell_borrow"

    case params[type][:when]
    when "At Market"
      params[type].except!(:when, "execute_at(1i)", "execute_at(2i)", "execute_at(3i)", "execute_at(4i)", "execute_at(5i)", :measure, :price_target)
      return
    when "Future"
      params[type].except!(:when, :measure, :price_target)
      params[type][:order_type] = @order_type
      @order = DateTimeTransaction.new(params[type].merge(user: current_user))
    when "Stop-Loss"
      params[type].except!(:when, "execute_at(1i)", "execute_at(2i)", "execute_at(3i)", "execute_at(4i)", "execute_at(5i)")
      params[type][:order_type] = @order_type
      @order = StopLossTransaction.new(params[type].merge(user: current_user))
    end
    
    if @order.place!(@stock_details)
      flash[:notice] = "Order successfully placed"
    else
      flash[:alert] = @order.errors.values.join if !@order.errors.blank?
    end
    redirect_to(stock_path(params[:stock_id]))
    return 
  end

  def load_portfolio(user_id = 0)
    if current_user
      @user = current_user
    else
      #Stop the method here if no params were sent through
      return if user_id.eql? 0
      @user = User.find(user_id)
    end

    # Stop the method here if we can't find the user
    return false unless @user

    @portfolio = {}.tap do |p|
      user_stocks = @user.user_stocks.includes(:stock).with_shares_owned
      user_shorts = @user.user_stocks.includes(:stock).with_shares_borrowed
      pending_date_time_transactions = @user.date_time_transactions.pending.upcoming
      processed_date_time_transactions = @user.date_time_transactions.processed
      pending_stop_loss_transactions = @user.stop_loss_transactions.pending
      processed_stop_loss_transactions = @user.stop_loss_transactions.processed
      stock_symbols = user_stocks.map { |s| s.stock.symbol }
      stock_details = Finance.stock_details_for_list(stock_symbols)
      short_symbols = user_shorts.map { |s| s.stock.symbol }
      short_details = Finance.stock_details_for_list(short_symbols)

      p[:current_value] = 0
      p[:cash] = @user.account_balance.to_f
      p[:purchase_value] = 0
      p[:stocks] = {}
      p[:shorts] = {}
      p[:pending_date_time_transactions] = pending_date_time_transactions 
      p[:processed_date_time_transactions] = processed_date_time_transactions 
      p[:pending_stop_loss_transactions] = pending_stop_loss_transactions
      p[:processed_stop_loss_transactions] = processed_stop_loss_transactions

      user_stocks.each do |user_stock|
        stock_symbol = user_stock.stock.symbol
        details = stock_details[stock_symbol]
        purchase_value = user_stock.cost_basis.to_f * user_stock.shares_owned.to_f
        current_price = details.current_price.to_f
        current_value = current_price * user_stock.shares_owned.to_f
        shares_owned = user_stock.shares_owned
        cost_basis = user_stock.cost_basis.to_f
        percent_gain = ((current_price - cost_basis) * 100 / cost_basis).round(1)
        percent_gain = 0.0 if percent_gain.to_s == "Infinity"
        p[:stocks][stock_symbol] = {
          name: user_stock.stock.name,
          current_price: current_price,
          shares_owned: shares_owned,
          current_value: current_value,
          cost_basis: cost_basis,
          capital_gain: current_price - cost_basis,
          percent_gain: percent_gain 
        }
        p[:current_value] += current_value
        p[:purchase_value] += purchase_value
      end

      user_shorts.each do |user_stock|
        stock_symbol = user_stock.stock.symbol
        details = short_details[stock_symbol]
        # Purchase value not needed. We never subtracted for shorted stocks.
        #purchase_value = user_stock.short_cost_basis.to_f * user_stock.shares_borrowed.to_f
        current_price = details.current_price.to_f
        current_value = ((user_stock.short_cost_basis.to_f - current_price) * user_stock.shares_borrowed.to_f)
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
        p[:purchase_value] += current_value
      end

      if p[:purchase_value].to_f == 0.0
        p[:percent_gain] = 0.0
      else
        p[:percent_gain] = ((p[:current_value] - p[:purchase_value]) * 100 / p[:purchase_value]).round(1)
      end
      p[:account_value] = (p[:cash].to_f + p[:current_value].to_f).round(2)
    end

  end

  def linkedin_share_connect(controller)
    client = LinkedIn::Client.new('xoc3a06gsosd', '41060V6v5K38dnV4', LINKEDIN_CONFIGURATION)
    request_token = client.request_token(:oauth_callback =>
                                             "https://#{request.host_with_port}/#{controller}/callback_linkedin")
    session[:rtoken] = request_token.token
    session[:rsecret] = request_token.secret
    redirect_to client.request_token.authorize_url
  end

  def facebook_share_connect(controller)
    session['oauth'] = Koala::Facebook::OAuth.new("331752936918078", "6dee4f074f905e98957e9328bf4d91a3", "https://#{request.host_with_port}/#{controller}/callback_facebook")
    redirect_to session['oauth'].url_for_oauth_code(:permissions => "publish_stream")
  end
end
