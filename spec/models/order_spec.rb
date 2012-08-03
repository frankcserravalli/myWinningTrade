require 'spec_helper'

describe "Order" do
  before do
    @user = create(:user)
    @user.update_attribute(:account_balance, 50000)
  end

  before(:all) do
    VCR.use_cassette('quote') do
      @stock_details = Finance.current_stock_details('AAPL')
    end
  end

  context "buying" do
    before do
      @order = Buy.new(user: @user, volume: 2)
    end

    it "should reflect a credit for buying a stock" do
      @stock_details.current_price = "20.00"

      @order.place!(@stock_details)
      @order.value.to_f.should == -(20.00 * 2.0)
    end

    it "should import a system stock if it does not yet exist" do
      @order.place!(@stock_details)

      @user.stocks.first.should_not be_nil
      @user.user_stocks.first.shares_owned.should == 2
    end

    it "should accept a buy for elligible users and stocks" do
      @order.place!(@stock_details).should be_true

      @user.reload.account_balance.to_f.should == 50000.0 + @user.orders.last.value.to_f
    end

    it "should not accept a buy for a user with insufficient funds" do
      @user.update_attribute(:account_balance, 0)
      @order.place!(@stock_details).should be_false
      @order.errors.should_not be_empty
    end

    it "should not accept buys for orders with negative volumes" do
      @order.volume = -100
      @order.place!(@stock_details).should be_false
      @order.errors.should_not be_empty
    end
  end
end
