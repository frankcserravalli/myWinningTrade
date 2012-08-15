class UserStock < ActiveRecord::Base
  belongs_to :user
  belongs_to :stock
  has_many :orders
  has_many :buys
  has_many :sells

  scope :with_shares_owned, where{ shares_owned > 0 }

  attr_accessible :stock

  structure do
    shares_owned  10**12, default: 0
    cost_basis :decimal, precision: 10, scale: 2
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
end
