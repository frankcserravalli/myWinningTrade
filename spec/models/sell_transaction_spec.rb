require 'spec_helper'

describe 'SellTransaction' do
  let(:user) { create(:user, account_balance: 50000) }
  let(:stock) { Stock.create!(name: 'Apple Inc.', symbol: 'AAPL') }
  let(:user_stock) { user.user_stocks.create!(stock: stock) }
  let(:transaction_fee) { Order::TRANSACTION_FEE }

  before(:all) do
    VCR.use_cassette('quote') do
      @stock_details = Finance.current_stock_details('AAPL')
    end
  end

  before(:each) do
    user_stock.update_attribute :shares_owned, 50
  end

  it 'does not sell more shares than the user owns' do
    sell_transaction = SellTransaction.new(volume: 60, user: user, stock: stock)
    sell_transaction.place!(@stock_details).should be_false
  end

  it 'sells shares if the user has sufficient volume' do
    sell_transaction = SellTransaction.new(volume: 50, user: user, stock: stock)
    sell_transaction.place!(@stock_details).should be_true
  end

  it 'creates multiple sell orders if selling across several buys' do
    user_stock.sells.count.should == 0

    new_buy(1.0, 25, user, user_stock)
    new_buy(1.0, 25, user, user_stock)
    sell_transaction = SellTransaction.new(volume: 40, user: user, stock: stock)
    sell_transaction.place!(@stock_details).should be_true

    sells = user_stock.sells
    sells.count.should == 2
    sells.first.volume.should == 15
    sells.last.volume.should == 25
  end

end

