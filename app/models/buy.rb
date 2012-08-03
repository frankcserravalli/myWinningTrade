class Buy < Order
  def place!(stock)
    order_price = volume.to_f * stock.current_price.to_f
    unless user.account_balance >= order_price
      self.errors.add(:user, "Insufficient funds, $#{(order_price - user.account_balance).round} more required to complete purchase.")
      return false
    end

    super
    transaction do
      self.value = -order_price
      self.price = stock.current_price
      user.update_attribute(:account_balance, user.account_balance - order_price)
      self.user_stock.update_attribute(:shares_owned, self.user_stock.shares_owned.to_i + volume.to_i)

      if save
        return true
      else
        raise ActiveRecord::Rollback
      end
    end
  end
end
