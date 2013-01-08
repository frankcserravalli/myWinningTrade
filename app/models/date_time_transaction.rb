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

  def execute!(stock)
  end

  def execute_at_is_in_future
    if execute_at < Time.now
      errors.add(:execute_at, "Trade must be set in the future")
    end
  end

  def check_for_valid_volume
    if order_type == 'Sell' && volume > self.user_stock.shares_owned
      errors.add(:volume, "Cannot sell more shares than you own")
    end
  end

end
