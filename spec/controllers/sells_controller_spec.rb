require 'spec_helper'
require 'devise'
describe SellsController do
  include Devise::TestHelpers
  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @user = FactoryGirl.create(:user, :sign_in)
    sign_in @user
  end
  it 'should create a sell for a user' do
    @apple = Stock.where(symbol: 'AAPL').first_or_create!(name: 'Apple')
    VCR.use_cassette('quote') do
      @stock_details = Finance.stock_details_for_symbol('AAPL')
    end
    @buy = Buy.new(user: @user, volume: 20)
    @buy.place!(@stock_details)
    VCR.use_cassette('quote') do
      post :create, stock_id: 'AAPL', sell: { volume: 5, when: 'At Market' }
    end
    @user.user_stocks.first.shares_owned.to_i.should eq(15)
    response.should redirect_to(stock_path('AAPL'))
  end

  it 'should redirect to the stock details page if the buy was unsuccessful' do
    Sell.any_instance.stubs(:place!).returns(false)
    VCR.use_cassette('quote') do
      post :create, stock_id: 'AAPL', sell: {}
    end
    response.should redirect_to(stock_path('AAPL'))
  end
end
