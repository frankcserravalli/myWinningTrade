require 'spec_helper'

describe StockController do
  before do
    authenticate
  end

  it "should display details of a given stock" do
    VCR.use_cassette('quote') do
      get :show, id: 'AAPL'
    end

    response.should render_template 'show'
  end

  it "should redirect to the dashboard if a stock is not found" do
    VCR.use_cassette('quote_not_found') do
      get :show, id: '153.MX'
    end

    response.should redirect_to dashboard_path
  end

  context "JSON API" do
    it "should return details for a list of stocks" do
      VCR.use_cassette('multiple_quotes') do
        get :details, stocks: ['AAPL', 'GOOG', 'fake']
      end

      json = MultiJson.load(response.body)
      json.keys.should include 'AAPL', 'GOOG'
    end

    it "should return the price history for a given stock" do
      VCR.use_cassette('stock_price_history') do
        get :price_history, id: 'AAPL'
      end

      json = MultiJson.load(response.body)
      json['symbol'].should == 'AAPL'
      json['price_history'].keys.should include 'live', 'historical'
    end

    it "should return suggestions for a search term" do
      VCR.use_cassette('search_for_stock') do
        get :search, term: 'app'
      end

      json = MultiJson.load(response.body)

      apple = json.detect { |s| s['symbol'] == 'AAPL' }
      apple.should_not be_nil
      apple['name'].should == 'Apple Inc.'
    end
  end
end
