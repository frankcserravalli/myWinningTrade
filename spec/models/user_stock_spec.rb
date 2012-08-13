require 'spec_helper'

describe 'UserStock' do
	let(:user) { create(:user, account_balance: 50000) }
  let(:stock) { Stock.create!(name: 'Apple Inc.', symbol: 'AAPL') }
  let(:user_stock) { user.user_stocks.create!(stock: stock) }
	let(:transaction_fee) { 6 }

  def cost_basis(stock_price, stock_volume)
    (((stock_price * stock_volume) + transaction_fee) / stock_volume).abs
  end

  def new_buy(stock_price, stock_volume)
    transaction_total = (stock_price * stock_volume) + transaction_fee
    transaction_total *= -1 # negative amount for buys
    buy = Buy.new(user: user, user_stock: user_stock, volume: stock_volume)
    buy.price = stock_price
    buy.value = transaction_total
    buy.save!
    buy
  end

  def new_sell(stock_price, stock_volume)
    transaction_total = stock_price * stock_volume
    sell = Sell.new(user: user, user_stock: user_stock, volume: stock_volume)
    sell.price = stock_price
    sell.value = transaction_total
    sell.save!
    sell
  end

  describe 'buying' do

    it 'sets the volume_remaining when creating a buy order' do
      buy = new_buy(1.0, 50)
      buy.volume_remaining.should == 50
    end

    it 'calculates the cost basis for a new buy order' do
      stock_price = 1.0
      stock_volume = 50
      buy = new_buy(stock_price, stock_volume)
      buy.cost_basis.should == cost_basis(stock_price, stock_volume)
    end

    it 'recalculates the average cost basis for user_stock on a new buy order' do
      first_buy = new_buy(1.0, 50)
      user_stock.reload.cost_basis.should == first_buy.cost_basis

      second_buy = new_buy(1.1, 50)

      recalculated_cost_basis = (56.0 + 61.0) / (50 + 50)
      user_stock.reload.cost_basis.should == recalculated_cost_basis
    end

  end

  describe 'selling' do

    it 'subtracts from volume_remaining when new sell order is created' do
      buy = new_buy(1.0, 50)
      sell = new_sell(1.0, 40)
      buy.reload.volume_remaining.should == 10
    end

    it 'subtracts from volume_remaining on multiple buys when a new sell order is created' do
      # creates multiple sell orders
    end

    it 'recalculates'

    it 'calculates capital gain / loss for each sale'

  end

end
