class Order < ActiveRecord::Base
  TRANSACTION_FEE = 6.0

  scope :of_stock, lambda{ |stock_symbol| where('stock.symbol ' => stock_symbol) }
  scope :with_limit, lambda { |lim| limit(lim) }

  belongs_to :user_stock
  belongs_to :user

  has_one :stock, through: :user_stock

  attr_accessor :when
  attr_accessor :measure
  attr_accessor :price_target
  attr_accessor :execute_at

  structure do
    price  :decimal, precision: 10, scale: 2, validates: :numericality
    volume 10**12, validates: { numericality: { greater_than: 0, message: "Did not process a buy with zero volume." } }
    volume_remaining 10**12
    type   index: true, limit: 15

    # Value is the total effect on the account balance (i.e. negative for buys)
    value  :decimal, precision: 10, scale: 2, validates: :numericality
    cost_basis :decimal, precision: 10, scale: 2
    capital_gain :decimal, precision: 10, scale: 2
    timestamps
  end

  attr_accessible :user, :volume, :user_stock, :volume_remaining
  validates_presence_of :user_stock_id, :user_id

  def place!(stock)
    system_stock = Stock.where(symbol: stock.symbol).first_or_create!(name: stock.name)
    unless (self.user_stock = user.user_stocks.where(stock_id: system_stock.id).first)
      self.user_stock = user.user_stocks.create!(stock: system_stock)
    end
  end

end

