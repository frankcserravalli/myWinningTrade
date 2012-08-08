class Sell < Order

  after_save :reduce_buy_volume_remaining, on: :create

  def place!(stock)
    order_price = volume.to_f * stock.current_price.to_f
    self.user_stock = self.user.user_stocks.includes(:stock).where('stocks.symbol' => stock.symbol).first

    unless self.user_stock && self.user_stock.shares_owned.to_i >= volume.to_i
      self.errors.add(:user, "You cannot sell #{volume} shares in #{stock.symbol} as you only currently own #{self.user_stock.shares_owned.to_i}")
      return false
    end

    super
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

  protected
  def reduce_buy_volume_remaining
    # TODO replace this with an association:
    # Also, migrant doesnt seem to add created_at, so we're sorting by id here
    buys = Buy.where(user_stock_id: self.user_stock.id).with_volume_remaining.order(:id)

    volume_to_reduce = self.volume
    buys.each do |buy|
      if volume_to_reduce > 0
        buy_volume_remaining = buy.volume_remaining
        reducable_amount = [buy_volume_remaining, volume_to_reduce].min
        buy_volume_remaining -= reducable_amount
        volume_to_reduce -= reducable_amount
        puts buy_volume_remaining
        buy.update_attribute :volume_remaining, buy_volume_remaining
      end
    end
  end

end
