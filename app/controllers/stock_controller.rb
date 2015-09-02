require 'yahoo_finanza'

class StockController < ApplicationController
  def dashboard
    # This gives us the results of the leaders in the leader board
  end

  def show
    @stock = Finance.stock_details_for_symbol(symbol)
    @user_stock = signed_user.user_stocks.includes(:stock).where('stocks.symbol' => symbol).first
    # Setting up the new records in anticipation of an user creating an order
    @buy_order = Buy.new
    @short_sell_borrow_order = ShortSellBorrow.new
    @sell_order = SellTransaction.new
    @date_time_buy_transaction = DateTimeTransaction.new
    @date_time_sell_transaction = DateTimeTransaction.new
    @date_time_short_sell_borrow_transaction = DateTimeTransaction.new
    @stop_loss_buy_transaction = StopLossTransaction.new
    @stop_loss_sell_transaction = StopLossTransaction.new
    @stop_loss_short_transaction = StopLossTransaction.new
    if @stock.nil?
      alert = I18n.t(
        'flash.stock.invalid_symbol', symbol: symbol,
        default: 'No stock matches the symbol %{symbol}.')
      redirect_to dashboard_path, alert: alert
    end
  end

  def details
    @details = Finance.stock_details_for_list(params[:stocks].to_a)
    render json: @details
  end

  def price_history
    @price_history = Finance.stock_price_history(params[:id])
    render json: @price_history.marshal_dump
  end

  def search
    @suggestions = Finance.search_for_stock(params[:term].to_s)
    render json: @suggestions
  end

  def portfolio
    render partial: 'account/portfolio'
  end

  def tutorial
    render 'account/tutorial'
  end

  def markets
    ycl = YahooFinanza::Client.new
    @suggestions = ycl.active_symbols
    @stock = Finance.stock_details_for_list(@suggestions)
    render 'account/markets'
  end

  def popular_market
    ycl = YahooFinanza::Client.new
    @suggestions = ycl.active_symbols
    @stock = Finance.stock_details_for_list(@suggestions)
    render partial: 'stock/suggest'
  end

  def nyse_market
    ycl = YahooFinanza::Client.new
    @nyse_suggestions = ycl.symbols_by_market('nyse')[0..50]
    @nyse = Finance.stock_details_for_list(@nyse_suggestions)
    render partial: 'stock/nyse'
  end

  def nasdaq_market
    ycl = YahooFinanza::Client.new
    @nasdaq_suggestions = ycl.symbols_by_market('nasdaq')[0..50]
    @nasdaq = Finance.stock_details_for_list(@nasdaq_suggestions)
    render partial: 'stock/nasdaq'
  end

  def top_100
    ycl = YahooFinanza::Client.new
    @top_100_suggestions = ycl.sp_symbols(100)
    @top_100 = Finance.stock_details_for_list(@top_100_suggestions)
    render partial: 'stock/top'
  end

  def leaderboards
    leader_board_results = UserAccountSummary.find_top_results(signed_user.id)
    @world_leader_board = leader_board_results[0]
    pp @world_leader_board
    @class_leader_board = leader_board_results[1]
    render 'account/leaderboards'
  end

  def trading_analysis
    @stock_summary = signed_user.stock_summary
  end

  private

  def symbol
    params.require(:id).upcase
  end
end
