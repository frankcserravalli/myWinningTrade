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

  def place!(stock)
    # This method will place a stop_loss_transaction order
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

  def check_for_valid_volume
    if order_type == 'Sell' && volume > self.user_stock.shares_owned
      errors.add(:volume, "Cannot sell more shares than you own")
    end
  end

end
