require 'spec_helper'

describe 'UserStock' do
	let(:user) { create(:user, account_balance: 50000) }
  let(:stock) { Stock.create!(name: 'Apple Inc.', symbol: 'AAPL') }
  let(:user_stock) { user.user_stocks.create!(stock: stock) }
	let(:transaction_fee) { Order::TRANSACTION_FEE }

  context 'buying' do

    # TODO this needs to be moved
    it 'sets the volume_remaining when creating a buy order' do
      buy = new_buy(1.0, 50, user, user_stock)
      buy.volume_remaining.should == 50
    end

    # TODO this needs to be moved
    it 'calculates the cost basis for a new buy order' do
      stock_price = 1.0
      stock_volume = 50
      buy = new_buy(stock_price, stock_volume, user, user_stock)
      buy.cost_basis.should == cost_basis(stock_price, stock_volume)
    end

    it 'recalculates the average cost basis for user_stock on a new buy order' do
      first_buy = new_buy(1.0, 50, user, user_stock)
      user_stock.reload.cost_basis.should == first_buy.cost_basis

      second_buy = new_buy(1.1, 50, user, user_stock)

      recalculated_cost_basis = -(first_buy.value + second_buy.value) / (first_buy.volume + second_buy.volume)
      user_stock.reload.cost_basis.round(2).should == recalculated_cost_basis.round(2)
    end
  end

end
