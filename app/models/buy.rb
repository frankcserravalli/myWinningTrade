class Buy < Order

  scope :with_volume_remaining, where{ volume_remaining > 0 }

  before_create :calculate_cost_basis
  before_create :set_volume_remaining
  after_create :recalculate_user_stock_cost_basis

  def place!(stock)

    if stock.current_price.to_f <= 0.0
      self.errors.add(:base, "Cannot purchase a stock that has zero value.")
      return false
    end

    order_price = volume.to_f * stock.current_price.to_f + TRANSACTION_FEE

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

      save.tap { |successful| raise ActiveRecord::Rollback unless successful }
    end
  end

  protected
  def calculate_cost_basis
    self.cost_basis = (self.value / self.volume).abs
  end

  def set_volume_remaining
    self.volume_remaining ||= self.volume
  end

  def recalculate_user_stock_cost_basis
    self.user_stock.recalculate_cost_basis!
  end

end
