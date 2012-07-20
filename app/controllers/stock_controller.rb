class StockController < ApplicationController
  def show
  	symbol = params[:symbol]
    @stock = Finance.current_stock_details(symbol)

    if @stock.nil?
      error = I18n.t('flash.stock.invalid_symbol', symbol: symbol, default: 'No stock matches the symbol %{symbol}.')
      redirect_to root_path, error: error
    end
  end
end
