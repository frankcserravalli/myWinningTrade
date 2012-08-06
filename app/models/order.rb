class Order < ActiveRecord::Base
  belongs_to :user_stock
  belongs_to :user

  structure do
    price  :decimal, precision: 10, scale: 2, validates: :numericality
    volume 10**12, validates: { numericality: { greater_than: 0 } }
    type   index: true, limit: 15

    # Value is the total effect on the account balance (i.e. negative for buys)
    value  :decimal, precision: 10, scale: 2, validates: :numericality
  end

  attr_accessible :user, :volume, :user_stock
  validates_presence_of :user_stock_id, :user_id

  def place!(stock)
    system_stock = Stock.where(symbol: stock.symbol).first_or_create!(name: stock.name)

    unless (self.user_stock = user.user_stocks.where(stock_id: system_stock.id).first)
      self.user_stock = user.user_stocks.create!(stock: system_stock)
    end
  end
end

