class StockController < ApplicationController
  def show
  	symbol = params[:id].upcase
    @stock = Finance.current_stock_details(symbol)
    if @stock.nil?
      alert = I18n.t('flash.stock.invalid_symbol', symbol: symbol, default: 'No stock matches the symbol %{symbol}.')
      redirect_to root_path, alert: alert
    end
  end

  def details
    @details = Finance.current_stock_details(params[:id])
    render json: @details.marshal_dump
  end

  def price_history
    @price_history = Finance.stock_price_history(params[:id])
    render json: @price_history
  end
end
