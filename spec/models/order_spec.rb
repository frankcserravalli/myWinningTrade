require 'spec_helper'

describe "Order" do
  before(:all) do
    VCR.use_cassette('quote') do
      @stock_details = Finance.stock_details_for_symbol('AAPL')
    end
  end

  let(:user) { create(:user, account_balance: 50000) }
  let(:stock) { Stock.create!(name: 'Apple Inc.', symbol: 'AAPL') }
  let(:user_stock) { user.user_stocks.create!(stock: stock) }
  let(:transaction_fee) { Order::TRANSACTION_FEE }

  context "buying" do
    before do
      @order = Buy.new(user: user, volume: 2)
    end

    it "should reflect a credit for buying a stock" do
      @stock_details.ask = "20.00"

      @order.place!(@stock_details)
      @order.value.to_f.should == (20.00 * 2.0) + Order::TRANSACTION_FEE
    end

    it "should import a system stock if it does not yet exist" do
      @order.place!(@stock_details)

      user.stocks.first.should_not be_nil
      user.user_stocks.first.shares_owned.should == 2
    end

    it "should accept a buy for elligible users and stocks" do
      @order.place!(@stock_details).should be_true
      user.reload.account_balance.to_f.should == 50000.0 -  user.orders.last.value.to_f
    end

    it "should not accept a buy for a user with insufficient funds" do
      user.update_attribute(:account_balance, 0)
      @order.place!(@stock_details).should be_false
      @order.errors.should_not be_empty
    end

    it "should not accept buys for orders with negative volumes" do
      @order.volume = -100
      @order.place!(@stock_details).should be_false
      @order.errors.should_not be_empty
    end
  end

  context "selling" do
    it 'subtracts from buy volume_remaining when new sell order is created' do
      buy = new_buy(1.0, 50, user, user_stock)

      order = Sell.new(user: user, volume: 40, buy: buy)
      order.place!(@stock_details).should be_true

      buy.reload.volume_remaining.should == 10
    end

    it 'calculates capital gain / loss on each sale relating to its relevant buy' do
      current_price = @stock_details.ask.to_f
      stock_volume = 50.0
      buy = new_buy(current_price, stock_volume, user, user_stock)

      cost_basis = ((current_price * stock_volume) + transaction_fee) / stock_volume
      buy.cost_basis.should == cost_basis

      order = Sell.new(user: user, volume: 40, buy: buy)
      order.place!(@stock_details).should be_true

      order.capital_gain.round(2).to_i.should == -(transaction_fee / stock_volume).round(2).to_i # since stock price hasn't changed

    end

    it 'should have a positive capital gain when the stock price increases' do
      buy_price = 0.01
      stock_volume = 50.0
      buy = new_buy(buy_price, stock_volume, user, user_stock)

      order = Sell.new(user: user, volume: 40, buy: buy)
      order.place!(@stock_details).should be_true

      order.capital_gain.round(2).should > 0

    end

    it 'should have a negative capital gain when the stock price decreases' do
      buy_price = 99999.00
      stock_volume = 50.0
      buy = new_buy(buy_price, stock_volume, user, user_stock)

      order = Sell.new(user: user, volume: 40, buy: buy)
      order.place!(@stock_details).should be_true

      order.capital_gain.round(2).should < 0

    end
  end

  context "short sell borrowing" do
    before do
      @order = ShortSellBorrow.new(user: user, volume: 2)
    end
    it "should not accept borrow orders with negative volumes" do
      @order.volume = -100
      @order.place!(@stock_details).should be_false
      @order.errors.should_not be_empty
    end
    it "should not accept a buy for a user with insufficient funds" do
      user.update_attribute(:account_balance, 0)
      @order.place!(@stock_details).should be_false
      @order.errors.should_not be_empty
    end
    it "should have order type of ShortSellBorrow" do
      @order.type.should == "ShortSellBorrow"
    end
  end

  context "short sell covering" do
    it 'subtracts from short sell borrow volume_remaining when new short sell cover order is created' do
      short_sell_borrow = new_short_sell_borrow(1.0, 50, user, user_stock)

      order = ShortSellCover.new(user: user, volume: 40, short_sell_borrow: short_sell_borrow)
      order.place!(@stock_details).should be_true

      short_sell_borrow.reload.volume_remaining.should == 10
    end

    it "has a positive capital gain when the stock price declines" do
      borrow_price = 99999.05 # Start with a really high value
      stock_volume = 50.0
      short_sell_borrow = new_short_sell_borrow(borrow_price, stock_volume, user, user_stock)

      order = ShortSellCover.new(user: user, volume: 40, short_sell_borrow: short_sell_borrow)
      order.place!(@stock_details).should be_true

      order.capital_gain.round(2).should > 0
    end

    it "has a negative capital gain when the stock price increases" do
      borrow_price = 0.01 # Start with a really low value
      stock_volume = 50.0
      short_sell_borrow = new_short_sell_borrow(borrow_price, stock_volume, user, user_stock)

      order = ShortSellCover.new(user: user, volume: 40, short_sell_borrow: short_sell_borrow)
      order.place!(@stock_details).should be_true

      order.capital_gain.round(2).should < 0
    end

  end

end
