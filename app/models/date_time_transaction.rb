# == Schema Information
#
# Table name: date_time_transactions
#
#  id            :integer          not null, primary key
#  user_stock_id :integer
#  user_id       :integer
#  volume        :integer
#  order_type    :string(255)
#  status        :string(255)      default("pending")
#  execute_at    :timestamp(6)
#  updated_at    :timestamp(6)
#  created_at    :timestamp(6)
#

class DateTimeTransaction < ActiveRecord::Base
  validate :execute_at_is_in_future
  validate :check_for_valid_volume

  scope :pending,   where( status: 'pending' )
  scope :processed, where( status: 'processed' ) 
  scope :failed,    where( status: 'failed' )
  scope :upcoming,  where('execute_at > ?',Time.now).order('execute_at ASC')

  belongs_to :user_stock
  belongs_to :user

  has_one :stock, through: :user_stock

  structure do
    volume      10**12,       validates: { numericality: { greater_than: 0, message: "Did not process a buy with zero volume." } }
    order_type        'ShortSellBorrow',  validates: :presence
    status      'Processed',  default: 'pending'
    execute_at  :datetime,    validates: :presence
    timestamps
  end


  attr_accessible :user, :user_stock, :volume, :order_type, :status, :execute_at
  
  def place!(stock)
    # This method will place a date_time_transaction order
    # that will be executred at the specific date time
    # by a cron job.
    system_stock = Stock.where(symbol: stock.symbol).first_or_create!(name: stock.name)
    unless (self.user_stock = user.user_stocks.where(stock_id: system_stock.id).first)
      self.user_stock = user.user_stocks.create!(stock: system_stock)
    end
    self.save
  end


  def execute_at_is_in_future
    if execute_at < Time.now && status != "processed" && status != "failed"
      errors.add(:execute_at, "Trade must be set in the future")
    end
  end

  def check_for_valid_volume
    if order_type == 'Sell' && volume > self.user_stock.shares_owned
      errors.add(:volume, "Cannot sell more shares than you own")
    end
  end

  def self.evaluate_pending_orders
    puts "evaluating pending date time orders"
    orders = DateTimeTransaction.pending.upcoming
    puts "#{orders.size}"
    orders.each do |order|
      order_model = order.order_type
      order_model = "SellTransaction" if order_model == "Sell"
      order_model = order_model.constantize
      puts order_model.new 
      symbol = order.user_stock.stock.symbol
      place_the_order = false

      puts "user #{order.user_id} would like to #{order.order_type} #{symbol} when date is #{order.execute_at}"
      puts order.inspect
      puts "checking price for #{symbol}..." 
      details = Finance.current_stock_details(symbol)
      current_price = details.current_price.to_f
      puts "current price for #{symbol} is #{current_price}"
      puts "comparing prices..."

      new_order = {}
      new_order[:volume] = order.volume

      order_to_execute = order_model.new(new_order.merge(user: order.user))

      now = Time.now

      puts "current time is #{now}"

      if now > order.execute_at
        puts "Ready to execute"
        place_the_order = true
      else
        puts "Not ready to execute"
      end

      if place_the_order
        puts "placing the order..."
        puts order_to_execute.to_json
        transaction do
          if order_to_execute.place!(details)
            order.status = "processed"
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

