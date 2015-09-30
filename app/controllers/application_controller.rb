include ActionView::Helpers::DateHelper
class ApplicationController < ActionController::Base
  include UsersHelper
  require 'yahoo_finanza'
  # before_filter :require_acceptance_of_terms, if: :signed_user
  before_filter :load_portfolio

  def require_acceptance_of_terms
    redirect_to terms_path and return unless signed_user && signed_user.accepted_terms?
  end

  # Api authentication
  def valid_user_id
    @user = User.find_by_id(params[:user_id])
    return @user if @user
    respond_with "Invalid user"
  end

  # Inside buys, sells, and short_sell_borrows controllers
  def when_to_execute_order(type)
    @stock_details = Finance.stock_details_for_symbol(params[:stock_id]) or raise ActiveRecord::RecordNotFound

    @order_type = type

    case params[type][:when]
    when "At Market"
      params[type].except!(:when, "execute_at(1i)", "execute_at(2i)", "execute_at(3i)", "execute_at(4i)", "execute_at(5i)", :measure, :price_target)
      return
    when "Future"
      params[type].except!(:when, :measure, :price_target)
      params[type][:order_type] = @order_type
      @order = DateTimeTransaction.new(params[type].merge(user: signed_user))
    when "Stop-Loss"
      params[type].except!(:when, "execute_at(1i)", "execute_at(2i)", "execute_at(3i)", "execute_at(4i)", "execute_at(5i)")
      params[type][:order_type] = @order_type
      @order = StopLossTransaction.new(params[type].merge(user: signed_user))
    end

    if @order
      if@order.place!(@stock_details)
        flash[:notice] = "Order successfully placed"
      else
        flash[:alert] = @order.errors.values.join if !@order.errors.blank?
      end
    end
    redirect_to(stock_path(params[:stock_id]))
  end

  # I've set the user_id default as zero in case user_id is not sent through
  def load_portfolio(user_id = 0)

    @user = signed_user || User.find(user_id)
    # pp "User Stocks: #{@user.user_stocks.includes(:stock).first.stock.symbol}"
    @portfolio = {}.tap do |p|
      user_stocks = @user.user_stocks.includes(:stock, :orders).with_shares_owned
      user_shorts = @user.user_stocks.includes(:stock, :orders).with_shares_borrowed
      pending_date_time_transactions = @user.date_time_transactions.pending.upcoming
      processed_date_time_transactions = @user.date_time_transactions.processed
      pending_stop_loss_transactions = @user.stop_loss_transactions.pending
      processed_stop_loss_transactions = @user.stop_loss_transactions.processed
      stock_symbols = user_stocks.map { |s| s.stock.symbol }
      stock_details = if stock_symbols.count > 0
                        if stock_symbols.count > 1
                          Finance.stock_details_for_list(stock_symbols)
                        else
                          OpenStruct.new(
                              stock_symbols.first.to_sym => Finance.stock_details_for_symbol(stock_symbols.first))
                        end
                      else
                        OpenStruct.new
                      end
      short_symbols = user_shorts.map { |s| s.stock.symbol }
      short_details = if short_symbols.count > 0
                        if short_symbols.count > 1
                          Finance.stock_details_for_list(short_symbols)
                        else
                          OpenStruct.new(
                            short_symbols.first.to_sym => Finance.stock_details_for_symbol(short_symbols.first))
                        end
                      else
                        OpenStruct.new
                      end

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
        current_price = details.Ask.to_f unless details.nil?
        current_value = current_price * user_stock.shares_owned.to_f
        shares_owned = user_stock.shares_owned
        cost_basis = user_stock.cost_basis.to_f
        percent_gain = ((current_price - cost_basis) * 100 / cost_basis).round(1)
        percent_gain = 0.0 if percent_gain.to_s == "Infinity"
        p[:stocks][stock_symbol] = {
          id: user_stock.stock.id,
          name: user_stock.stock.name,
          current_price: current_price,
          shares_owned: shares_owned,
          current_value: current_value,
          cost_basis: cost_basis,
          capital_gain: current_price - cost_basis,
          percent_gain: percent_gain,
          orders: user_stock.orders.limit(5)
        }
        p[:current_value] += current_value
        p[:purchase_value] += purchase_value
      end

      user_shorts.each do |user_stock|
        stock_symbol = user_stock.stock.symbol
        details = short_details[stock_symbol]
        # Purchase value not needed. We never subtracted for shorted stocks.
        #purchase_value = user_stock.short_cost_basis.to_f * user_stock.shares_borrowed.to_f
        current_price = details.Ask.to_f
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
          percent_gain: (-(current_price - short_cost_basis) * 100 / short_cost_basis).round(1),
          orders: user_stock.orders.limit(5)
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
    # Here we create a client connection to LinkedIn
    client = LinkedIn::Client.new('xoc3a06gsosd', '41060V6v5K38dnV4', LINKEDIN_CONFIGURATION)

    # We then tell LinkedIn where we want them to send the client to after they are done logging in
    request_token = client.request_token(:oauth_callback =>
                                             "https://#{request.host_with_port}/#{controller}/callback_linkedin")

    # Setting up some sessions for future reference for the user
    session[:rtoken] = request_token.token

    session[:rsecret] = request_token.secret

    # Here we redirect the user to LinkedIn login page
    redirect_to client.request_token.authorize_url
  end

  def facebook_share_connect(controller)
    # Create a new session with Facebook given our api credentials
    session['oauth'] = Koala::Facebook::OAuth.new("331752936918078", "6dee4f074f905e98957e9328bf4d91a3", "https://#{request.host_with_port}/#{controller}/callback_facebook")

    # Redirect to Facebook login page
    redirect_to session['oauth'].url_for_oauth_code(:permissions => "publish_stream")
  end

  def after_sign_in_path_for(_resource)
    if signed_user.group == 'teacher'
      groups_url
    else
      profile_url
    end
  end

  def signed_user
    if user_signed_in?
      current_user
    else
      user = current_or_guest_user
      user.name = 'Guest User'
      user.save
      user
    end
  end

  def market_groups
    groups = OpenStruct.new(
      big: Array.new, mid: Array.new,
      small: Array.new, micro: Array.new)

    ycl = YahooFinanza::Client.new
    signed_user.stocks.each do |stock|
      quote = ycl.quote(stock.symbol)
      quote[:id] = stock.id
      market_cap = quote.Ask.to_f * quote.Volume.to_f
      case market_cap
      when 0..300000000 then groups.micro.push(quote)
      when 300000000..2000000000 then groups.small.push(quote)
      when 2000000000..10000000000 then groups.mid.push(quote)
      else groups.big.push(quote) end
    end
    groups
  end

  def chart_values
    slices = OpenStruct.new(
      big: 0, mid: 0, small: 0, micro: 0,
      cash: signed_user.account_balance)
    groups = market_groups
    groups.to_h.keys.each do |key|
      groups[key].each do |stock|
        user_stock = signed_user.user_stocks.where(id: stock.id).first
        shares_owned = user_stock ? user_stock.shares_owned : 0
        total = stock.Ask.to_f * shares_owned
        slices[key] += total
      end
    end
    slices.to_h
  end

  def featured_stocks (limit = 4)
    ycl = YahooFinanza::Client.new
    ycl.popular_stock_quotes.shuffle[0..limit]
  end

  helper_method :signed_user, :featured_stocks, :chart_values
end
