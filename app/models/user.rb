class User < ActiveRecord::Base
  OPENING_BALANCE = 50000
  has_many :orders
  has_many :user_stocks
  has_many :stocks, through: :user_stocks
  has_many :date_time_transactions
  has_many :stop_loss_transactions

  structure do
  	email			       'developers@platform45.com'#, validates: :presence
  	name 			       'Joe Bloggs'
    provider 	       'linkedin', limit: 16, index: true, validates: :presence
    uid 			       '1234', index: true, validates: :presence
    account_balance  :decimal, scale: 2, precision: 10, default: 0.0
    accepted_terms   :boolean, default: false
  end

  attr_protected :account_balance
  after_initialize :create_initial_balance

  def self.find_or_create_from_auth_hash(auth_hash)
    where(provider: auth_hash[:provider], uid: auth_hash[:uid]).first_or_initialize.tap do |user|
  	  user.name = auth_hash[:info][:name] if auth_hash[:info]
  	  user.save
  	end
  end

  def display_name
    (name.blank?)? email : name
  end

  def export_orders_as_csv
    CSV.generate do |csv|
      csv << ['Symbol', 'Name', 'Type', 'Time', 'Volume', 'Bid/Ask Price', 'Net Asset Value', 'Cost Basis', 'Capital Gain/Loss', 'Tax Liability']

      orders.includes(:stock).all.each do |order|
        order.cost_basis = (order.cost_basis.to_f * order.volume.to_f).round(2)
        total_capital_gain = (order.capital_gain.to_f * order.volume.to_f).round(2)
        tax_liability = (order.capital_gain.to_f * 0.3).round(2)
        csv << [order.stock.symbol, order.stock.name, order.type.titleize, order.created_at, order.volume, order.price, order.value.abs, order.cost_basis, total_capital_gain, tax_liability].collect(&:to_s)
      end
    end
  end

  def stock_summary
    user_stocks = self.user_stocks.includes(:stock)

    @stock_summary = {}.tap do |s|
      s[:stocks] = {}
      s[:summary] = {}
      s[:orders] = {}

      # Is total_capital equal to the total amount of money invested?
      total_capital = 0

      net_income_before_taxes = 0

      taxes = 0

      net_losses = 0

      net_revenue = 0

      # Looping through Each User Stock
      user_stocks.each do |user_stock|

        # Establishing variables here
        stock_symbol = user_stock.stock.symbol

        revenue = 0

        tax_liability = 0

        returns = 0

        order_types = []

        capital_at_risk = (user_stock.shares_owned * user_stock.cost_basis)

        total_capital += capital_at_risk

        # Looping through orders of of an user's stocks
        self.orders.of_users_stock(user_stock.id).each do |order|

          # Inserting info from each order into variables for the PDF
          stock_revenue_calculation = (order.capital_gain.to_f * order.volume.to_f)

          revenue += stock_revenue_calculation

          tax_liability += (order.capital_gain.to_f * 0.3)

          returns += (order.capital_gain.to_f - tax_liability)

          # Finding the net loss and net revenue of each stock
          if stock_revenue_calculation < 0
            net_losses += stock_revenue_calculation
          else
            net_revenue += stock_revenue_calculation
          end

          # Finding the cost basis of each order
          if order.type.eql? "Short Sell Cover" or order.type.eql? "Sell"
            cost_basis = order.volume * order.price
          else
            cost_basis = 0
          end

          # Finding the capital gain for each order, and if it doesn't exist assigning it $0.00
          if order.capital_gain.nil?
            capital_gain_loss = 0
          else
            capital_gain_loss = order.capital_gain
          end

          # Here I am grabbing each order and injecting it into the hash, used for the Orders Details summary in the PDF
          s[:orders][order.created_at] = {
            symbol: user_stock.stock.symbol,
            name: user_stock.stock.name,
            type: order.type,
            time: order.created_at,
            volume: order.volume,
            bid_ask_price: order.price,
            net_asset_value: (order.volume * order.price),
            cost_basis: cost_basis,
            capital_gain_loss: capital_gain_loss,
            tax_liability: tax_liability
          }
        end

        s[:stocks][stock_symbol] = {
          name: user_stock.stock.name,
          revenue: revenue.round(2),
          tax_liability: tax_liability.round(2),
          capital_at_risk: capital_at_risk.round(2),
          returns: returns.round(2),
          holding_period: 1
        }

        net_income_before_taxes += returns

        taxes += tax_liability
      end

      net_income_after_taxes = net_income_before_taxes - taxes

      s[:summary] = {
        net_income_before_taxes: net_income_before_taxes.round(2),
        net_income_after_taxes: net_income_after_taxes.round(2),
        sums: net_income_before_taxes.round(2),
        net_income: net_income_after_taxes.round(2),
        gross_profit: net_income_before_taxes.round(2),
        net_revenue: net_revenue,
        net_losses: net_losses,
        taxes: taxes.round(2),
        total_capital: total_capital.round(2)
      }

      # Here I'm inserting the capital invested percentage into each stock
      s[:stocks].each_key do |stock_symbol|
        s[:stocks][stock_symbol][:capital_invested_percentage] = (s[:stocks][stock_symbol][:capital_at_risk] / s[:summary][:total_capital]).round(2) * 100
      end
    end
  end

  def create_trading_analysis_pdf
    stock_summary = self.stock_summary

    number_of_stocks = stock_summary[:stocks].length

    # Here I am sorting the arrays revenue from lowest to highest.
    # This will help in producing the Profit and Loss/Capital at Risk statement
    sorted_revenues = stock_summary[:stocks].sort_by do |k,v|
      stock_summary[:stocks][k][:revenue]
    end

    sorted_capital = stock_summary[:stocks].sort_by do |k,v|
      stock_summary[:stocks][k][:capital_at_risk]
    end

    # This puts it in an ascending order
    sorted_open_positions = stock_summary[:stocks].sort_by do |k,v|
      -stock_summary[:stocks][k][:returns]
    end

    # Stock Details Section
    summary = ""

    array = []

    stock_number_at = 0

    composite_revenue = 0

    composite_tax_liability = 0

    composite_capital_at_risk = 0

    composite_returns = 0

    more_than_one_stock_exists = false

    sorted_open_positions.each_with_index do |index, value|
      unless sorted_open_positions[value][1][:capital_at_risk].eql? 0
        if more_than_one_stock_exists.eql? true
            composite_revenue += sorted_open_positions[value][1][:revenue]

            composite_tax_liability += sorted_open_positions[value][1][:tax_liability]

            composite_capital_at_risk += sorted_open_positions[value][1][:capital_at_risk]

            composite_returns += sorted_open_positions[value][1][:returns]
        else
            more_than_one_stock_exists = true

            summary += "<tr><td>" + sorted_open_positions[value][0].to_s + "</td>"

            summary += "<td>" + sorted_open_positions[value][1][:name].to_s + "</td>"

            summary += "<td>" + sorted_open_positions[value][1][:revenue].round(2).to_s + "</td>"

            summary += "<td>" + sorted_open_positions[value][1][:tax_liability].round(2).to_s + "</td>"

            summary += "<td>" + sorted_open_positions[value][1][:capital_at_risk].round(2).to_s + "</td>"

            summary += "<td>" + sorted_open_positions[value][1][:returns].round(2).to_s + "</td></tr>"
        end
      end
    end

    summary += "<tr><td>--</td>"

    summary += "<td>Composite</td>"

    summary += "<td>" + composite_revenue.round(2).to_s + "</td>"

    summary += "<td>" + composite_tax_liability.round(2).to_s + "</td>"

    summary += "<td>" + composite_capital_at_risk.round(2).to_s + "</td>"

    summary += "<td>" + composite_returns.round(2).to_s + "</td></tr>"

    # Profit and Loss Section
    profit_stocks = ""

    loss_stocks = ""

    profit_stock_exists = false

    loss_stock_exists = false

    two_profit_stocks_exists = false

    two_loss_stocks_exists = false

    composite_profit_number = 0.0

    composite_losses_number = 0.0

    sorted_revenues.reverse.each_with_index do |index, value|
      if sorted_revenues[value][1][:revenue] >= 0

        # Dealing with profits
        if profit_stock_exists.eql? false
          profit_stocks += "<div class='row-fluid'><div class='span4 offset2'>#{sorted_revenues[value][0].to_s}</div>"

          profit_stocks += "<div class='span4'>#{sorted_revenues[value][1][:revenue].to_s}</div></div>"

          profit_stock_exists = true
        else
          if two_profit_stocks_exists.eql? false
            two_profit_stocks_exists = true
          end

          composite_profit_number += sorted_revenues[value][1][:revenue]
        end
      else

        # Dealing with losses
        if loss_stock_exists.eql? false
          loss_stocks += "<div class='row-fluid'><div class='span4 offset2'>#{sorted_revenues[value][0].to_s}</div>"

          loss_stocks += "<div class='span4'>(#{sorted_revenues[value][1][:revenue].abs.to_s})</div></div>"

          loss_stock_exists = true
        else
          if two_loss_stocks_exists.eql? false
            two_loss_stocks_exists = true
          end

          composite_losses_number -= sorted_revenues[value][1][:revenue]
        end
      end
    end

    # Here we are inserting all the other stocks into a composite row
    unless two_profit_stocks_exists.eql? false
      profit_stocks += "<div class='row-fluid'><div class='span4 offset2'>Composite</div>"

      profit_stocks += "<div class='span4'>#{composite_profit_number}</div></div>"
    end


    unless two_loss_stocks_exists.eql? false
      loss_stocks += "<div class='row-fluid'><div class='span4 offset2'>Composite</div>"

      loss_stocks += "<div class='span4'>(#{composite_losses_number})</div></div>"
    end


    # Capital at Risks Section
    capital_at_risk_stocks = ""

    more_than_one_stock = false

    composite_capital_at_risk = 0.0

    composite_capital_percentage = 0.0

    capital_at_risk_top_stock_percentage = 0.0

    # Here I'm creating HTML for the Capital At Risks Section
    sorted_capital.reverse.each_with_index do |index, value|
      unless more_than_one_stock.eql? true
        capital_at_risk_stocks += "<tr><td>#{index[0]}</td>"

        capital_at_risk_stocks += "<td class='pagination-centered'>#{index[1][:capital_at_risk]}</td>"

        capital_at_risk_stocks += "<td class='pagination-centered'>#{index[1][:capital_invested_percentage]}</td></tr>"

        more_than_one_stock = true
      else
        composite_capital_at_risk += index[1][:capital_at_risk]

        composite_capital_percentage += index[1][:capital_invested_percentage]
      end
    end

    # Here I'm inserting the composite collection of stocks
    capital_at_risk_stocks += "<tr><td>Composite</td>"

    capital_at_risk_stocks += "<td class='pagination-centered'>#{composite_capital_at_risk.round(2).to_s}</td>"

    capital_at_risk_stocks += "<td class='pagination-centered'>#{composite_capital_percentage.round(2).to_s}</td></tr>"

    # Here we are setting up the data for the pie chart
    capital_at_risk_data = [["Symbol", "Percentage at Risk"]]

    number_of_times_sorted_capital_looped = 0

    sorted_capital.reverse.each_with_index do |index, value|
      number_of_times_sorted_capital_looped += 1

      capital_at_risk_data << [ index[0], index[1][:capital_invested_percentage].to_f ]
    end

    # Risk Statistics Section
    borrowed = 0

    @short_sell_covers = ShortSellCover.where(user_id: self.id)

    @short_sell_borrows = ShortSellBorrow.where(user_id: self.id)

    @short_sell_covers.each do |order|
      borrowed -= order.value
    end

    @short_sell_borrows.each do |order|
      borrowed -= order.value
    end

    # Setting the borrowed money amount to two decimal places
    borrowed = sprintf('%.2f', borrowed)





    list_of_stocks = []
    # Finding the average holding period for every stock
    the_summary = Order.where(user_id: self.id).order("created_at DESC").reverse
    the_summary.each do |order|
      list_of_stocks << Stock.find(UserStock.find(order.user_stock_id).stock_id).symbol
      if order.type.eql?

    end

    # Html is variable that is used as what is rendered on the PDF
    html = '<head>
              <script type="text/javascript" src="https://www.google.com/jsapi"></script>
              <script type="text/javascript">
                google.load("visualization", "1", {packages:["corechart"]});
                google.setOnLoadCallback(drawChart);
                function drawChart() {
                  var data = google.visualization.arrayToDataTable(' + capital_at_risk_data.to_s + ');
                  var options = {
                    title: "Capital at Risk"
                  };
                  var chart = new google.visualization.PieChart(document.getElementById("chart_div"));
                  chart.draw(data, options);
                }
              </script>
            </head>' + list_of_stocks.inspect + '
            <h2>Open Positions</h2>
            <div class="row-fluid">
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
                <tbody>' + summary + '</tbody>
              </table>
            </div>
            <div class="row-fluid">
              <div class="span6 row-fluid statement-border">
                <div class="pagination-centered">Profit and Loss Statement</div>
                <div class="pagination-centered">' + self.name + '</div>
                <div class="pagination-centered">For the Period Ended: ' + Date.today.to_s + '</div>
                <div class="row-fluid">
                  <div class="span7 offset1">Trading Activities</div>
                </div>
                <div class="row-fluid">
                  <div class="span2 offset1 pagination-centered">Revenues</div>
                </div>' + profit_stocks +
                '<div class="row-fluid">
                  <span class="span7 offset1">Net Revenues</span>
                  <span class="span4 pagination-centered">' + stock_summary[:summary][:net_revenue].to_s + '</span>
                </div>
                <div class="row-fluid">
                  <div class="span2 offset1 pagination-centered">Losses</div>
                </div>' + loss_stocks +
                '<div class="row-fluid">
                  <span class="span7 offset1">Net Losses</span>
                  <span class="span4 pagination-centered">(' + stock_summary[:summary][:net_losses].abs.round(2).to_s + ')</span>
                </div>
                <div class="row-fluid">
                  <span class="span7 offset1">Gross Profit</span>
                  <span class="span4 pagination-centered">' + (stock_summary[:summary][:net_revenue] + stock_summary[:summary][:net_losses]).round(2).to_s + '</span>
                </div>
                <div class="row-fluid">
                  <span class="span7 offset1">Incurred Tax Liability</span>
                  <span class="span4 pagination-centered">(' + (stock_summary[:summary][:net_income_after_taxes] - stock_summary[:summary][:net_income_before_taxes]).round(2).to_s + ')</span>
                </div>
                <div class="row-fluid">
                  <span class="span7 offset1">Net Income</span>
                  <span class="span4 pagination-centered">' + stock_summary[:summary][:net_income].to_s + '</span>
                </div>
              </div>

              <div class="span6 statement-border">
                <div class="pagination-centered">Capital at Risk</div>
                <div class="pagination-centered">' + self.name + '</div>
                <div class="pagination-centered">For the Period Ended: ' + Date.today.to_s + '</div>
                <div class="row-fluid"
                  <div class="span7 offset1">Starting Capital</div>
                  <div class="span4">$50,000</div>
                </div>
                <div class="span4">Additional Paid in Capital</div>
                <br>
                <table class="table table-striped">
                  <thead>
                    <tr>
                      <th>Symbol</th>
                      <th>Capital at Risk</th>
                      <th>Capital Invested/Total Capital</th>
                    </tr>
                  </thead>
                  <tbody>' + capital_at_risk_stocks  + '</tbody>
                </table>
              </div>
            </div>

            <div class="row-fluid">
              <div class="span6 row-fluid statement-border">
                <div class="pagination-centered">Risk Statistics</div>
                <div class="pagination-centered">' + self.name + '</div>
                <div class="pagination-centered">For the Period Ended: ' + Date.today.to_s + '</div>
                <br>
                <div class="row-fluid">
                  <span class="span4">Leverage</span>
                  <span class="span2">$' + borrowed + '</span>
                </div>
                <br>
                <div class="row-fluid">
                  <span class="span4">Average Holding Period</span>
                  <span class="span2">$760.00</span>
                </div>
                <br>
                <div class="row-fluid">
                  <span class="span4">Benchmark B</span>
                  <span class="span2">' + Finance.grab_alpha_or_beta.round(2).to_s + '</span>
                </div>
                <br>
                <div class="row-fluid">
                  <span class="span4">Trader a</span>
                  <span class="span2">' + (Finance.grab_alpha_or_beta * 100).round(2).to_s + '%</span>
                </div>
                <br>
                <div class="row-fluid">
                  <span class="span4">R-squared</span>
                  <span class="span2">$760.00</span>
                </div>
              </div>
              <div class="row-fluid span4">
                <div id="chart_div" class="span12" style=" height: 300px;"></div>
              </div>
            </div>'

    html
  end

  protected
  def create_initial_balance
    self.account_balance ||= OPENING_BALANCE
  end
end



=begin
# Orders Summary pdf




            <h2>Orders Summary</h2>
            <div class="row-fluid">
              <table class="table table-striped span12">
                <thead>
                  <tr>
                    <th>Symbol</th>
                    <th>Name</th>
                    <th>Type</th>
                    <th>Time</th>
                    <th>Volume</th>
                    <th>Bid Asking Price</th>
                    <th>Net Asset Value</th>
                    <th>Cost Basis</th>
                    <th>Capital Gain/Loss</th>
                    <th>Tax Liability</th>
                    <th>Holding Period</th>
                  </tr>
                </thead>
                <tbody>' + orders_summary + '</tbody>
              </table>
            </div>


    # Order Details Section
    orders_summary = ""
    stock_summary[:orders].each_key do |created_at|
      orders_summary += "<tr><td>" + stock_summary[:orders][created_at][:symbol].to_s + "</td>"
      orders_summary += "<td>" + stock_summary[:orders][created_at][:name].to_s + "</td>"
      orders_summary += "<td class='pagination-centered'>" + stock_summary[:orders][created_at][:type].to_s + "</td>"
      orders_summary += "<td>" + stock_summary[:orders][created_at][:time].to_date.to_s + "</td>"
      orders_summary += "<td class='pagination-centered'>" + stock_summary[:orders][created_at][:volume].to_s + "</td>"
      orders_summary += "<td>" + stock_summary[:orders][created_at][:bid_ask_price].to_s + "</td>"
      orders_summary += "<td>" + stock_summary[:orders][created_at][:net_asset_value].to_s + "</td>"
      orders_summary += "<td>" + stock_summary[:orders][created_at][:cost_basis].to_s + "</td>"
      orders_summary += "<td>" + stock_summary[:orders][created_at][:capital_gain_loss].to_s + "</td>"
      orders_summary += "<td>" + stock_summary[:orders][created_at][:tax_liability].round(2).to_s + "</td>"
      orders_summary += "<td>" + stock_summary[:orders][created_at][:holding_period].to_s + "</td></tr>"
    end

=end
