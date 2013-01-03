class DateTimeTransaction < ActiveRecord::Base
 
  scope :pending,   where{ status: 'pending' }
  scope :processed, where{ status: 'processed' }
  scope :failed,    where{ status: 'failed' }

  belongs_to :user_stock
  belongs_to :user

  has_one :stock, through: :user_stock

  structure do
    volume      10**12,       validates: { numericality: { greater_than: 0, message: "Did not process a buy with zero volume." } }
    type        'ShortSell',  validates: :presence
    status      'Processed',  default: 'pending'
    executed_at :datetime
    timestamps
  end

  attr_accessible :user, :user_stock, :volume, :type, :status, :executed_at
  
  def place!(stock)
    # This method will place a date_time_transaction order
    # that will be executred at the specific date time
    # by a cron job.
    system_stock = Stock.where(symbol: stock.symbol).first_or_create!(name: stock.name)
    unless (self.user_stock = user.user_stocks.where(stock_id: system_stock.id).first)
      self.user_stock = user.user_stocks.create!(stock: system_stock)
    end
  end

  def execute!(stock)
  end

end
