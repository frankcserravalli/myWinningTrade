class UserStock < ActiveRecord::Base
  belongs_to :user
  belongs_to :stock
  has_many :orders
  has_many :buys
  has_many :sells
  has_many :short_sell_borrows
  has_many :short_sell_covers

  attr_accessible :stock

  scope :with_shares_owned, where{ shares_owned > 0 }
  scope :with_shares_borrowed, where{ shares_borrowed > 0 }

  structure do
    shares_owned  10**12, default: 0
    cost_basis :decimal, precision: 10, scale: 2
    shares_borrowed  10**12, default: 0
    short_cost_basis :decimal, precision: 10, scale: 2
  end

  def recalculate_cost_basis!
    total_cost = total_volume = 0
    buys = self.buys.with_volume_remaining

    buys.each do |buy|
      buy_total = buy.cost_basis * buy.volume_remaining
      total_cost += buy_total
      total_volume += buy.volume_remaining
    end

    new_cost_basis = total_volume == 0 ? 0 : (total_cost / total_volume)

    self.update_attribute :cost_basis, new_cost_basis
  end

  def recalculate_short_cost_basis!
    total_cost = total_volume = 0 
    short_sell_borrows = self.short_sell_borrows.with_volume_remaining

    short_sell_borrows.each do |buy|
      buy_total = buy.cost_basis * buy.volume_remaining
      total_cost += buy_total 
      total_volume += buy.volume_remaining
    end

    new_cost_basis = total_volume == 0 ? 0 : (total_cost / total_volume)

    self.update_attribute :short_cost_basis, new_cost_basis
  end

end
