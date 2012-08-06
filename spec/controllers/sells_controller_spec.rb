require 'spec_helper'

describe SellsController do
  it "should create a buy for a user" do
    @user = authenticate
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
end
