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

  def orders_summary
    user_stocks = self.user_stocks.includes(:stock)
    @order_summary = {}.tap do |s|
      s[:stocks] = {}

      s[:summary] = {}

      user_stocks.each do |user_stock|

        self.orders.of_users_stock(user_stock.id).each do |order|

        end

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

        capital_at_risk = 0

        tax_liability = 0

        returns = 0

        avg_holding_period = 0

        order_types = []

        # Looping through orders of of an user's stocks
        self.orders.of_users_stock(user_stock.id).each do |order|

          # Inserting info from each order into variables for the PDF
          stock_revenue_calculation = (order.capital_gain.to_f * order.volume.to_f)

          revenue += stock_revenue_calculation

          capital_at_risk += order.cost_basis.to_f

          tax_liability += (order.capital_gain.to_f * 0.3)

          returns += (order.capital_gain.to_f - tax_liability)

          total_capital += capital_at_risk

          # Finding the net loss and net revenue of each stock
          if stock_revenue_calculation < 0
            net_losses += stock_revenue_calculation
          else
            net_revenue += stock_revenue_calculation
          end

          # This is a test for avg holding period, may or may not get rid of it
          order_types << order.type << order.created_at

          # Finding the cost basis of each order
          if order.type.eql? "Short Sell Cover" or order.type.eql? "Sell"
            cost_basis = order.volume * order.price
          else
            cost_basis = 0
          end

          # Here I am grabbing each order and injecting it into the hash, used for the Orders Details summary
          s[:orders][stock_symbol] = {
              symbol: user_stock.stock.symbol,
              name: user_stock.stock.name,
              type: order.type,
              time: order.created_at,
              volume: order.volume,
              bid_ask_price: order.price,
              net_asset_value: (order.volume * order.price),
              cost_basis: cost_basis,
              capital_gain_loss: order.capital_gain,
              tax_liability: tax_liability,
              holding_period: "1"
          }
        end



        capital_invested_percentage = (capital_at_risk / total_capital)

        s[:stocks][stock_symbol] = {
            name: user_stock.stock.name,
            revenue: revenue.round(2),
            tax_liability: tax_liability.round(2),
            capital_at_risk: capital_at_risk.round(2),
            returns: returns.round(2),
            order_types: order_types
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



  protected
  def create_initial_balance
    self.account_balance ||= OPENING_BALANCE
  end
end

