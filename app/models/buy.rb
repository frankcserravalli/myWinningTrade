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

class Buy < Order

  scope :with_volume_remaining, where{ volume_remaining > 0 }

  before_create :calculate_cost_basis
  before_create :set_volume_remaining
  after_create :recalculate_user_stock_cost_basis

  attr_accessor :flash_cover

  def place!(stock, *params)
    if stock.Ask.to_f <= 0.0
      self.errors.add(:base, "Cannot purchase a stock that has zero value.")
      return false
    end

    order_price = volume.to_f * stock.Ask.to_f + TRANSACTION_FEE

    if user.account_balance < order_price
      self.errors.add(:user, "Insufficient funds, $#{(order_price - user.account_balance).round} more required to complete purchase.")
      return false
    end

    super

    shares_to_short = 0

    if self.volume <= self.user_stock.shares_borrowed
      shares_to_short = self.volume
      self.volume = 0
    end
    if self.volume > self.user_stock.shares_borrowed && self.user_stock.shares_borrowed > 0
      shares_to_short = self.user_stock.shares_borrowed
      self.volume = self.volume - self.user_stock.shares_borrowed
    end

    if shares_to_short.to_i > 0
      short_params = {}
      short_params[:volume] = shares_to_short
      short_order = ShortTransaction.new(short_params.merge(user: user))
      if short_order.place!(stock)
        self.flash_cover = "Successfully covered #{short_order.volume} #{stock.symbol} for $#{short_order.value.round(2)}"
      end
      if self.volume == 0
        return false
      end
    end

    transaction do
      self.value = order_price
      self.price = stock.Ask
      user.update_attribute(:account_balance, user.account_balance - order_price)
      self.user_stock.update_attribute(:shares_owned, self.user_stock.shares_owned.to_i + volume.to_i)
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
    self.user_stock.recalculate_cost_basis!
  end

end
