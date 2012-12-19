class ShortTransaction < ActiveRecord::Base
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

    unless self.user_stock && self.user_stock.shares_borrowed.to_i >= volume.to_i
      self.errors.add(:user, "You cannot cover #{volume} shares in #{stock.symbol} as you only currently are borrowing #{self.user_stock.shares_borrowed.to_i}")
      return false
    end

    shorts = user_stock.short_sell_borrows.with_volume_remaining.order(:created_at)
    volume_remaining_to_sell = volume.to_i

    ShortSellCover.transaction do
      shorts.each do |short|
      	this_sale_volume = [short.volume.to_i, volume_remaining_to_sell].min
        cover = ShortSellCover.new(volume: this_sale_volume, user: user, short_sell_borrow: short)
        cover.place!(stock)
        volume_remaining_to_sell -= this_sale_volume
        break if volume_remaining_to_sell == 0
      end
    end

    user_stock.reload.recalculate_short_cost_basis!
    return true
  end

end
