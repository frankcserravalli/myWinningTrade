class UserShort < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user
  belongs_to :stock
  has_many :orders
  has_many :short_sell_borrows
  has_many :short_sell_covers

  attr_accessible :stock

  scope :with_shares_owned, where{ shares_owned > 0 }

  structure do
    shares_owned  10**12, default: 0
    cost_basis :decimal, precision: 10, scale: 2
  end

  def recalculate_cost_basis!
  	total_cost = total_volume = 0
  	short_sell_borrows = self.short_sell_borrows.with_volume_remaining

  	short_sell_borrows.each do |short_sell_borrow|
  		short_sell_borrow_total = short_sell_borrow.cost_basis * short_sell_borrow.volume_remaining
  		total_cost += short_sell_borrow_total
  		total_volume += short_sell_borrow.volume_remaining
    end

    new_cost_basis = total_volume == 0 ? 0 : (total_cost / total_volume)

  	self.update_attribute :cost_basis, new_cost_basis
  end
end
