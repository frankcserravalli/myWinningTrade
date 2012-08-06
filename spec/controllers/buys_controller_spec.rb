require 'spec_helper'

describe BuysController do
  it "should create a buy for a user" do
    @user = authenticate

    VCR.use_cassette('quote') do
      post :create, stock_id: 'AAPL', buy: {
        volume: 2
      }
    end

    @user.user_stocks.collect { |s| s.stock.symbol }.should include('AAPL')
    response.should redirect_to(stock_path('AAPL'))
  end
end
