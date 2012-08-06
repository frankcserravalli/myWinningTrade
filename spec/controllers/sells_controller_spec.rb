require 'spec_helper'

describe SellsController do
  before do
    @user = authenticate
  end

  it "should create a buy for a user" do
    @apple = Stock.where(symbol: 'AAPL').first_or_create!(name: 'Apple')
    @user_stock = @user.user_stocks.create!(stock: @apple)
    @user_stock.update_attribute(:shares_owned, 100)

    VCR.use_cassette('quote') do
      post :create, stock_id: 'AAPL', sell: {
        volume: 50
      }
    end

    @user_stock.reload.shares_owned.to_i.should == 50
    response.should redirect_to(stock_path('AAPL'))
  end

  it "should redirect to the stock details page if the buy was unsuccessful" do
    Sell.any_instance.stubs(:place!).returns(false)

    VCR.use_cassette('quote') do
      post :create, stock_id: 'AAPL', sell: {}
    end

    response.should redirect_to(stock_path('AAPL'))
  end
end
