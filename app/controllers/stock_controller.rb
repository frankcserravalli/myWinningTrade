class StockController < ApplicationController
  def show
  	symbol = params[:symbol]
    @stock = Finance.current_stock_details(symbol)
    redirect_to root_path, notice: I18n.t('stock.invalid_symbol', symbol: symbol) unless @stock
  end
end
