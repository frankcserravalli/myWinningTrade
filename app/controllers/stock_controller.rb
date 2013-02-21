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
    @stock_summary = current_user.stock_summary
  end

  # TODO We need to move this somewhere else
  class Analysis < Prawn::Document
    def to_pdf(stock_summary)

      # Summary Section
      stock_summary[:stocks].each do |key, value|
        text key.to_s
        value.each do |key2, value2|
          text key2.to_s
          # This is to create a space
          text " "
          text value2.to_s
        end
      end
      stock_summary[:summary].each do |key, value|
        text key.to_s
        # This is to create a space
        text " "
        value.to_s
      end

      start_new_page

      # Profit Loss Section
      text "Trading Activities"

      stock_summary[:stocks].each do |key, value|
        if stock_summary[:stocks][key][:revenue] < 0
          text "Stock has a Net Revenue"
          text "Name:"
          text stock_summary[:stocks][key][:name]

          text "Net Revenue:"
          text stock_summary[:stocks][key][:revenue].to_s
        else
          text "Stock has a Net Loss"
          text "Name:"
          text stock_summary[:stocks][key][:name]
          text "Net Revenue:"
          text stock_summary[:stocks][key][:revenue].to_s
        end
        text "Net Revenue:"
        text stock_summary[:summary][:net_revenue].to_s

        text "Net Losses:"
        text stock_summary[:summary][:net_losses].to_s

        text "Gross Profitability:"
        text stock_summary[:summary][:gross_profit].to_s


        text "Tax Liability Incurred:"
        text stock_summary[:summary][:taxes].to_s

        text "Net Income:"
        text stock_summary[:summary][:net_income].to_s
      end

      start_new_page

      # Capital At Risk Page

      stock_summary[:stocks].each_key do |stock_symbol|
        text "Symbol:"
        text stock_symbol

        text "Name:"
        stock_summary[:stocks][stock_symbol][:name]

        text "Capital At Risk:"
        text stock_summary[:stocks][stock_symbol][:capital_at_risk].to_s

        text "Percentage:"
        text stock_summary[:stocks][stock_symbol][:capital_invested_percentage].to_s
      end

      start_new_page

      #Graph page
      stock_summary[:stocks].each_key do |stock_symbol|
        text stock_symbol
        text stock_summary[:stocks][stock_symbol][:capital_invested_percentage].to_s
      end

      render
    end
  end

  def trading_analysis_pdf
    output = Analysis.new.to_pdf(current_user.stock_summary)

    respond_to do |format|
      format.pdf do
        send_data output, :filename => "trading_analysis.pdf",
                  :type => "application/pdf"
      end
    end
  end


end
