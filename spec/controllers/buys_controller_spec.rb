require 'spec_helper'

describe BuysController do
  before do
    @user = authenticate
  end

  it "should create a buy for a user" do
    VCR.use_cassette('quote') do
      post :create, stock_id: 'AAPL', buy: { volume: 2, when: "At Market" }
    end

    @user.user_stocks.collect { |s| s.stock.symbol }.should include('AAPL')

    response.should redirect_to(stock_path('AAPL'))
  end

  it "should redirect to the stock details page if the buy was unsuccessful" do
    Buy.any_instance.stubs(:place!).returns(false)

    VCR.use_cassette('quote') do
      post :create, stock_id: 'AAPL', buy: {}
    end

    response.should redirect_to(stock_path('AAPL'))
  end
end
