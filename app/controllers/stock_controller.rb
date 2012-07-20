class StockController < ApplicationController
  def show
  	symbol = params[:symbol].upcase
    @stock = Finance.current_stock_details(symbol)
    if @stock.nil?
      alert = I18n.t('flash.stock.invalid_symbol', symbol: symbol, default: 'No stock matches the symbol %{symbol}.')
      redirect_to root_path, alert: alert
    end
  end
end
