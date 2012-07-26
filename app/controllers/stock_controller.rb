class StockController < ApplicationController
  def show
    # CACHING to save dev time:
    # %w(off capture replay)
    cache = 'replay'

    # CACHING replay
    @stock = session[:stock] and return if cache =='replay'

  	symbol = params[:id].upcase
    @stock = Finance.current_stock_details(symbol)

    if @stock.nil?
      alert = I18n.t('flash.stock.invalid_symbol', symbol: symbol, default: 'No stock matches the symbol %{symbol}.')
      redirect_to root_path, alert: alert
    end

    # CACHING capture
    session[:stock] = @stock if cache == 'capture'

  end

  def details
    @details = Finance.stock_details_for_list(params[:stocks].to_a)
    render json: @details
  end

  def price_history
    @price_history = Finance.stock_price_history(params[:id])
    render json: @price_history.marshal_dump
  end
end
