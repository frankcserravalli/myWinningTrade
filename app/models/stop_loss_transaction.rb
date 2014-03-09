class StopLossTransaction < ActiveRecord::Base
  validate :check_for_valid_volume

  scope :pending,   where( status: 'pending' )
  scope :processed, where( status: 'processed' )
  scope :failed,    where( status: 'failed' )

  belongs_to :user_stock
  belongs_to :user

  has_one :stock, through: :user_stock

  structure do
    volume        10**12,       validates: { numericality: { greater_than: 0, message: "Did not process a buy with zero volume." } }
    order_type          'ShortSellBorrow',  validates: :presence
    status        'Processed',  default: 'pending'
    measure       'Above',      validates: :presence
    price_target  :decimal, presicion: 10, scale: 2, validates: :numericality
    executed_at   :datetime
    timestamps
  end

  attr_accessible :user, :user_stock, :volume, :order_type, :measure, :price_target, :status, :execute_at

  def place!(stock, *params)
    # This method will place a stop_loss_transaction order
    # that will be executed at the specific date time
    # by a cron job.
    system_stock = Stock.where(symbol: stock.symbol).first_or_create!(name: stock.name)
    unless (self.user_stock = user.user_stocks.where(stock_id: system_stock.id).first)
      self.user_stock = user.user_stocks.create!(stock: system_stock)
    end
    self.save
  end

  def check_for_valid_volume
    if order_type == 'Sell' && volume > self.user_stock.shares_owned
      errors.add(:volume, "Cannot sell more shares than you own")
    end
  end

  def self.evaluate_pending_orders
    puts "begin evaluating  pending stop loss orders..."
    orders = StopLossTransaction.pending
    puts "#{orders.size} orders"
    orders.each do |order|
      order_model = order.order_type
      puts "###LLL#### #{order_model}"
      order_model = "SellTransaction" if order_model == "Sell" or order_model == "sell"

      if order_model == "SellTransaction"
        puts "SELL TRANCASTION #### #{order_model}"

        order_model = order_model.constantize
      else
        puts "SOMETHING ELSE #### #{order_model}"

        # This deals with having underscores, then it breaks the words into an array then capitalize each word
        order_model = order_model.gsub("_", " ").split(" ").each{|word| word.capitalize!}.join("").constantize
      end

      symbol = order.user_stock.stock.symbol
      place_the_order = false

      puts "user #{order.user_id} would like to #{order.order_type} #{symbol} when price is #{order.measure} #{order.price_target}"
      puts "checking price for #{symbol}..." 
      details = Finance.current_stock_details(symbol)
      current_price = details.current_price.to_f
      puts "current price for #{symbol} is #{current_price}"
      puts "comparing prices..."

      new_order = {}
      new_order[:volume] = order.volume

      order_to_execute = order_model.new(new_order.merge(user: order.user))

      if order.measure == "Above"
        if current_price > order.price_target
          puts "executing a #{order.order_type} because current price #{current_price} > #{order.price_target}"
          place_the_order = true
        end
      end

      if order.measure == "Below"
        if current_price < order.price_target
          place_the_order = true
          puts "executing a #{order.order_type} because current price #{current_price} < #{order.price_target}"
        end
      end

      if place_the_order
        puts "placing the order..."
        puts order_to_execute.to_json

        transaction do
          if order_to_execute.place!(details)
            order.status = "processed"
            order.executed_at = Time.now
            puts "ORDER PLACED"
          else
            puts "ORDER NOT PLACED"
            order.status = "failed"
          end

          if order.save
            puts "order saved"
          else
            puts "order not saved"
            raise ActiveRecord::Rollback
          end
        end

      end
      puts "done evaluating pending orders"
    end
  end

end
