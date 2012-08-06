class Sell < Order
  def place!(stock)
    order_price = volume.to_f * stock.current_price.to_f
    self.user_stock = self.user.user_stocks.includes(:stock).where('stocks.symbol' => stock.symbol).first

    unless self.user_stock && self.user_stock.shares_owned.to_i >= volume.to_i
      self.errors.add(:user, "You cannot sell #{volume} shares in #{stock.symbol} as you only currently own #{self.user_stock.shares_owned.to_i}")
      return false
    end

    transaction do
      self.value = order_price
      self.price = stock.current_price
      user.update_attribute(:account_balance, user.account_balance + order_price)
      self.user_stock.update_attribute(:shares_owned, self.user_stock.shares_owned.to_i - volume.to_i)

      save.tap do |successful|
        raise ActiveRecord::Rollback unless successful
      end
    end
  end
end
