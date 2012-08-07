require 'spec_helper'

describe 'UserStock' do
	let(:user) { create(:user, account_balance: 50000) }
	let(:transaction_fee) { 6 }

  it 'calculates the cost basis for a new buy order' do
  	apple = Stock.create!(name: 'Apple Inc.', symbol: 'AAPL')
    user_stock = user.user_stocks.create!(stock: apple)

    transaction_total = ((stock_price = 1.0) * (stock_volume = 5)) + transaction_fee
    transaction_total *= -1 # negative amount for buys

    buy = Buy.new(user: user, user_stock: user_stock, volume: stock_volume)
    buy.price = stock_price
    buy.value = transaction_total
    buy.save!

    buy.cost_basis.should == (transaction_total / stock_volume).abs
  end

  it 'calculates the average cost basis for user_stock on a new buy order' do

  end

end
