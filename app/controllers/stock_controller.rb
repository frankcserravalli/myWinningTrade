class StockController < ApplicationController
  def dashboard
  end

  def show
  	symbol = params[:id].upcase
    @stock = Finance.current_stock_details(symbol)
    @user_stock = current_user.user_stocks.includes(:stock).where('stocks.symbol' => symbol).first

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
    # current_user.orders.total_summary

    # TODO combine summary per stock with total summary
    # I'm prefer to move all collection of stock information
    # into one method to prevent extra work,
    # unless there is a summary of users portfolio in the db, right
    # now I can't find it. Note that summary_per_stock must be taken
    # out of Order Model and replaced with summary_total, but I'm unsure
    # if summary_per_stock was a work in progress. More research necessary
    #


    user_stocks = current_user.user_stocks.includes(:stock)

    @stock_summary = {}.tap do |s|
      s = { :stocks => {}, :summary => {} }

      # We need to get a query of the total capital, first find out where it's
      # at in the model
      total_capital = 50000
      net_income_before_taxes = 0
      taxes = 0

      # Here we are handling all of the users stocks
      user_stocks.each do |user_stock|

        # Declaring some variables for the block that follows
        stock_symbol = user_stock.stock.symbol
        revenue = 0
        capital_at_risk = 0
        tax_liability = 0
        returns = 0
        avg_holding_period = 0

        # Here we are combining all the orders
        current_user.orders.of_users_stock(user_stock.id).each do |order|
          revenue += (order.capital_gain.to_f * order.volume.to_f).round(2)
          capital_at_risk += order.cost_basis.to_f
          tax_liability += (order.capital_gain.to_f * 0.3).round(2)
          returns += (order.capital_gain - tax_liability).round(2)

          # Variables needing worked on
          # How do I find avg holding period?
          avg_holding_period += 1

        end

        capital_invested_percentage = (capital_at_risk / total_capital).round(2)

        # Inserting the stocks into the hash key stocks
        s[:stocks][stock_symbol] = {
            name: user_stock.stock.name,
            revenue: revenue,
            capital_at_risk: capital_at_risk.round(2),
            tax_liability: tax_liability,
            returns: returns,
            capital_invested_percentage: capital_invested_percentage
        }

        net_income_before_taxes += returns
        taxes += tax_liability

        # Debugging
        Rails.logger.info capital_at_risk
        Rails.logger.info revenue
        Rails.logger.info tax_liability
        Rails.logger.info returns
        Rails.logger.info capital_invested_percentage

      end

      net_income_after_taxes = net_income_before_taxes - taxes
      gross_profit = net_income_before_taxes
      sums = net_income_before_taxes
      net_income = net_income_after_taxes

    end

    # Debugging
    Rails.logger.info user_stocks.to_json
    Rails.logger.info @stock_summary

  end
end
