class SellTransaction
  include ActiveModel::Validations
  include ActiveModel::Conversion

  def persisted?; false; end

  ATTRIBUTES = [:price, :volume, :value, :user, :stock, :user_stock]
  attr_accessor *ATTRIBUTES
  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) if ATTRIBUTES.include?(name.to_sym) }
  end

  def place!(stock)
    system_stock = Stock.where(symbol: stock.symbol).first_or_create!(name: stock.name)

    unless (self.user_stock = user.user_stocks.where(stock_id: system_stock.id).first)
      self.user_stock = user.user_stocks.create!(stock: system_stock)
    end

    unless self.user_stock && self.user_stock.shares_owned.to_i >= volume.to_i
      self.errors.add(:user, "You cannot sell #{volume} shares in #{stock.symbol} as you only currently own #{self.user_stock.shares_owned.to_i}")
      return false
    end

    buys = user_stock.buys.with_volume_remaining.order(:created_at)
    volume_remaining_to_sell = volume

    Sell.transaction do
      # TODO transaction fee (rollback if not enough cash after this sale?)
      buys.each do |buy|
      	this_sale_volume = [buy.volume, volume_remaining_to_sell].min
        sell = Sell.new(volume: this_sale_volume, user: user, buy: buy)
        sell.place!(stock)
        volume_remaining_to_sell -= this_sale_volume
        break if volume_remaining_to_sell == 0
      end
    end

    user_stock.reload.recalculate_cost_basis!
    return true
  end

end
