class ShortSellCover < Order
  attr_accessor :short_sell_borrow
  attr_accessible :short_sell_borrow

  def place!(stock)
    order_price = volume.to_f * stock.current_price.to_f
    self.user_stock = self.user.user_stocks.includes(:stock).where('stocks.symbol' => stock.symbol).first

    transaction do
      self.value = order_price
      self.price = stock.current_price
      self.capital_gain = -(stock.current_price.to_f - short_sell_borrow.cost_basis)

      short_sell_borrow.update_attribute :volume_remaining, (short_sell_borrow.volume_remaining - volume)
      user.update_attribute(:account_balance, user.account_balance - order_price)
      self.user_stock.update_attribute(:shares_borrowed, self.user_stock.shares_borrowed.to_i - volume.to_i)

      save.tap do |successful|
        raise ActiveRecord::Rollback unless successful
      end
    end
  end

end
