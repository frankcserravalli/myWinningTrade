class StockController < ApplicationController
  def dashboard
    @world_leaderboard = UserAccountSummary.order("capital_total DESC").limit(20)

    @class = GroupUser.find_by_user_id(current_user.id)

    @class_leaderboard = GroupUser.where(group_id: @class.group_id).includes(:user)
  end

  def show
  	symbol = params[:id].upcase

    @stock = Finance.current_stock_details(symbol)

    @user_stock = current_user.user_stocks.includes(:stock).where('stocks.symbol' => symbol).first

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
      alert = I18n.t('flash.stock.invalid_symbol', symbol: symbol, default: 'No stock matches the symbol %{symbol}.')
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

  def trading_analysis
    @stock_summary = current_user.stock_summary
  end
end

