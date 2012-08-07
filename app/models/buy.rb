class Buy < Order

  before_save :calculate_cost_basis, on: :create

  def place!(stock)
    order_price = volume.to_f * stock.current_price.to_f
    if user.account_balance < order_price
      self.errors.add(:user, "Insufficient funds, $#{(order_price - user.account_balance).round} more required to complete purchase.")
      return false
    end

    super
    transaction do
      self.value = -order_price
      self.price = stock.current_price
      user.update_attribute(:account_balance, user.account_balance - order_price)
      self.user_stock.update_attribute(:shares_owned, self.user_stock.shares_owned.to_i + volume.to_i)

      save.tap do |successful|
        raise ActiveRecord::Rollback unless successful
      end
    end
  end

  protected
  def calculate_cost_basis
    self.cost_basis = (self.value / self.volume).abs
  end

end
