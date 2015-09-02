# == Schema Information
#
# Table name: orders
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  price            :decimal(10, 2)
#  volume           :integer
#  type             :string(15)
#  value            :decimal(10, 2)
#  user_stock_id    :integer
#  created_at       :timestamp(6)
#  updated_at       :timestamp(6)
#  cost_basis       :decimal(10, 2)
#  volume_remaining :integer
#  capital_gain     :decimal(10, 2)
#

class ShortSellBorrow < Order
  # attr_accessible :title, :body
  scope :with_volume_remaining, where{ volume_remaining > 0 }

  before_create :calculate_cost_basis
  before_create :set_volume_remaining
  after_create :recalculate_user_stock_cost_basis

  def place!(stock, *params)
    if stock.Ask.to_f <= 0.0
      self.errors.add(:base, "Cannot purchase a stock that has zero value.")
      return false
    end

    order_price = volume.to_f * stock.Ask.to_f

    if user.account_balance < order_price
      self.errors.add(:user, "Insufficient funds, $#{(order_price - user.account_balance).round} more required to complete purchase.")
      return false
    end

    super
    transaction do
      self.value = order_price
      self.price = stock.Ask
      #user.update_attribute(:account_balance, user.account_balance - order_price)
      self.user_stock.update_attribute(:shares_borrowed, self.user_stock.shares_borrowed.to_i + volume.to_i)
      self.capital_gain = stock.Ask.to_f - self.cost_basis
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
    self.user_stock.recalculate_short_cost_basis!
  end

end
