class ShortSellCover < Order
  attr_accessor :short_sell_borrow
  attr_accessible :short_sell_borrow

  def place!(stock, *params)
    order_price = volume.to_f * stock.current_price.to_f
    self.user_stock = self.user.user_stocks.includes(:stock).where('stocks.symbol' => stock.symbol).first

    short_value = volume.to_f * stock.current_price.to_f
    buy_value = volume.to_f * short_sell_borrow.price.to_f
    account_balance_change = buy_value - short_value

    transaction do
      self.value = order_price
      self.price = stock.current_price
      self.capital_gain = -(stock.current_price.to_f - short_sell_borrow.cost_basis)

      # Here we calculate the transaction capital minus taxes
      transaction_capital_less_tax = (self.capital_gain -= (self.capital_gain.to_f * 0.3).round(2))

      # Here we look for the user's account summary
      user_account_summary = UserAccountSummary.find_by_user_id(user.id)

      # Check to see if account summary exists
      if user_account_summary
        # User account summary exists, so we just add capital gain - tax liability
        user_account_summary.capital_total += (transaction_capital_less_tax * self.volume)

        # Then save user account summary
        user_account_summary.save
      else
        # Here we create the variables used to calculate totals from all the orders
        total_capital_gain = 0.0

        total_tax_liability = 0.0

        # Since user account summary does not exist, we go through all transactions,
        # then sum up the capital gain(loss) less the tax incurred liability
        #Order.where(user_id: 4).where.('type: ? OR type: ?', "Sell", "ShortSellCover")
        Order.where(user_id: user.id).where(type: ["Sell", "ShortSellCover"]).each do |order|
          total_capital_gain += (order.capital_gain.to_f * order.volume.to_f).round(2)

          total_tax_liability += (order.capital_gain.to_f * 0.3).round(2)
        end

        # Create User Account Summary and add in total capital with transaction capital
        user_account_summary = UserAccountSummary.new

        user_account_summary.user_id = user.id

        user_account_summary.capital_total = transaction_capital_less_tax + (total_capital_gain - total_tax_liability)

        user_account_summary.save
      end

      # Finish off rest of the transaction with updating the database
      short_sell_borrow.update_attribute :volume_remaining, (short_sell_borrow.volume_remaining - volume)
      user.update_attribute(:account_balance, user.account_balance + account_balance_change)
      self.user_stock.update_attribute(:shares_borrowed, self.user_stock.shares_borrowed.to_i - volume.to_i)

      save.tap do |successful|
        raise ActiveRecord::Rollback unless successful
      end
    end
  end

end
