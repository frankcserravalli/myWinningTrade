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

=begin
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

      max_gain = 0

      max_loss = 0

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
          text "Net Loss:"
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

        #text "Max Gain"
        if stock_summary[:summary][:net_income] > max_gain
          max_gain = stock_summary[:summary][:net_income]
        end

        #text "Max Loss"
        if stock_summary[:summary][:net_income] > max_loss
          max_loss = stock_summary
        end

      end



      start_new_page

      # Max Gain vs Max Loss



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


      # Determine Capital asset pricing model
        # Risk free rate
        # beta of the security
          # covariance of market return with stock return
          # variance of market return
        # expected market return



      # capital at risk
      # average holding period
      # capital invested/total capital
      # risk free return
      # excess return
      # average
      # std dev
      # Benchmark ß
      # Trader α

      render
    end
  end
=end







  def trading_analysis_pdf
    #output = Analysis.new.to_pdf(current_user.stock_summary)
    html = '<h2>Summary</h2>
<table class="table table-striped">
  <thead>
    <tr>
      <th>Symbol</th>
      <th>Name</th>
      <th>Revenues</th>
      <th>Tax Liability</th>
      <th>Capital at Risk</th>
      <th>Returns</th>
      <th>Avg. Holding Period</th>
    </tr>
  </thead>
  <tbody>
  <tr>
    <td>Symbol</td>
    <td>Name</td>
    <td>Revenues</td>
    <td>Tax Liability</td>
    <td>Capital at Risk</td>
    <td>Returns</td>
    <td>Avg. Holding Period</td>
  </tr>
  <tr>
    <td>Symbol</td>
    <td>Name</td>
    <td>Revenues</td>
    <td>Tax Liability</td>
    <td>Capital at Risk</td>
    <td>Returns</td>
    <td>Avg. Holding Period</td>
  </tr>
  <tr>
    <td>Symbol</td>
    <td>Name</td>
    <td>Revenues</td>
    <td>Tax Liability</td>
    <td>Capital at Risk</td>
    <td>Returns</td>
    <td>Avg. Holding Period</td>
  </tr>
  </tbody>
</table>

<div class="row">
  <div class="span6 offset6">
    <table class="table">
      <tbody>
      <tr>
        <td>SUMS </td>
        <td>Number</td>
        <td>Number</td>
      </tr>
      <tr>
        <td>Net Income before Taxes</td>
        <td></td>
        <td>Number</td>
      </tr>
      <tr>
        <td>Net Income after Taxes</td>
        <td></td>
        <td>Number</td>
      </tr>
      </tbody>
    </table>
  </div>
</div>

<div class="row">
  <div class="span5">
    <div class="pagination-centered">Profit and Loss Statement</div>
    <div class="pagination-centered">Username</div>
    <div class="pagination-centered">For the Period Ended: 15-Feb-13</div>
    <div>Trading Activities</div>

    <div class="span2 pagination-centered">Revenues</div>
    <br>
      <div class="offset1 span1">AAPL</div>
      <div class="span1">374.62</div>
      <br>
      <div class="offset1 span1">AAPL</div>
      <div class="span1">374.62</div>
      <br>
    <span style="padding-right:190px;">Net Revenues</span>
    <span>$760.00</span>
    <br>

    <div class="span2 pagination-centered">Losses</div>
    <br>
    <div class="offset1 span1">AAPL</div>
    <div class="span1">374.62</div>
    <br>
    <div class="offset1 span1">AAPL</div>
    <div class="span1">374.62</div>
    <br>
    <span class="span2">Net Losses</span>
    <span class="span2">$760.00</span>
    <br>

    <span class="span2">Gross Profit</span>
    <span class="span2">$234.00</span>
    <br>

    <span class="span2">Incurred Tax Liability</span>
    <span class="span2">$76540.00</span>
    <br>

    <span class="span2">Net Income</span>
    <span class="span2">$444.00</span>
    <br>

  </div>

</div>


<div class="row">
  <div class="span6">
    <div class="pagination-centered">Capital at Risk</div>
    <div class="pagination-centered">Username</div>
    <div class="pagination-centered">For the Period Ended: 15-Feb-13</div>
    <div class="span2">Starting Capital</div>
    <br>
    <div class="span2">Additional Paid in Capital</div>
    <br>
    <br>
    <table class="table table-striped">
      <thead>
        <tr>
          <th>Symbol</th>
          <th>Capital at Risk</th>
          <th>Capital Invested/Total Capital</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Symbol</td>
          <td>Name</td>
          <td>Revenues</td>
        </tr>
      </tbody>
    </table>
  </div>
</div>

<div class="row">
  <div class="span6 row">
    <div class="pagination-centered">Risk </div>
    <div class="pagination-centered">Username</div>
    <div class="pagination-centered">For the Period Ended: 15-Feb-13</div>
    <br>
    <div class="row">
      <span class="span4">Leverage</span>
      <span class="span2">$760.00</span>
    </div>
    <br>
    <div class="row">
      <span class="span4">Average Holding Period</span>
      <span class="span2">$760.00</span>
    </div>
    <br>
    <div class="row">
      <span class="span4">Benchmark B</span>
      <span class="span2">$760.00</span>
    </div>
    <br>
    <div class="row">
      <span class="span4">Trader a</span>
      <span class="span2">$760.00</span>
    </div>
    <br>
    <div class="row">
      <span class="span4">R-squared</span>
      <span class="span2">$760.00</span>
    </div>
  </div>
</div>'

    kit = PDFKit.new(html, :page_size => 'Letter')
    kit.stylesheets << 'app/assets/stylesheets/pdf/pdf.css'
    kit.stylesheets << 'app/assets/stylesheets/pdf/bootstrap.min.css'

    output = kit.to_pdf

    respond_to do |format|
      format.pdf do
        send_data output, :filename => "trading_analysis.pdf",
                  :type => "application/pdf"
      end
    end
  end


end
