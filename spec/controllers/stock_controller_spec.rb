require 'spec_helper'
require 'devise'
describe StockController do
  include Devise::TestHelpers
  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @user = FactoryGirl.create(:user, :sign_in)
    sign_in @user
  end

  it 'should display details of a given stock' do
    VCR.use_cassette('quote') do
      get :show, id: 'AAPL'
    end

    expect(response.status).to eq 302
  end

  it 'should redirect to the dashboard if a stock is not found' do
    VCR.use_cassette('quote_not_found') do
      get :show, id: '153.MX'
    end

    response.should redirect_to dashboard_path
  end

  context 'JSON API' do
    it 'should return details for a list of stocks' do
      VCR.use_cassette('multiple_quotes') do
        get :details, stocks: ['AAPL', 'GOOG', 'fake']
      end
      json = MultiJson.load(response.body)
      json.map { |j| j['table']['symbol'] }.should include 'AAPL', 'GOOG'
    end

    it 'should return suggestions for a search term' do
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
