require 'spec_helper'

describe "Finance" do
  before do
    @api = Finance
  end

	it "should return the details of a given stock" do
		VCR.use_cassette('quote') do
			quote = @api.stock_details_for_symbol('AAPL')

			quote.symbol.should == 'AAPL'
			quote.name.should == 'Apple Inc.'

			[:name, :symbol, :ask, :open, :previous_close, :volume].each do |key|
				quote.respond_to?(key).should be_true
			end
		end
	end

  it "should return the nil if a stock symbol in the list is invalid" do
    VCR.use_cassette('multiple_quotes') do
      quote = @api.stock_details_for_list(['AAPL', 'GOOG', 'fake'])
      quote.map { |quote| quote.symbol.to_sym }.should == [:AAPL, :GOOG]
      quote.select { |quote| quote.symbol == 'fake' }.empty?.should eq true
    end
  end

  it "should return the details of a list of stocks" do
    VCR.use_cassette('multiple_quotes') do
      quote = @api.stock_details_for_list(['AAPL', 'GOOG'])
      quote.map { |quote| quote.symbol.to_sym }.should == [:AAPL, :GOOG]
      quote.select { |s| s.symbol == 'AAPL' }.first.symbol.should == 'AAPL'
    end
  end


  # This needs to be refactored both the code and spec
   pending it "should return the price of a stock every week day for the past 6 months" do
    cassette_date = Time.at(1348152000).to_date

    VCR.use_cassette('stock_price_history', :record => :new_episodes) do
      @history = @api.stock_price_history('AAPL')
      @history.symbol.should == 'AAPL'
      @history.name.should == 'Apple Inc.'

      dates = (@history.price_history[:historical]+@history.price_history[:live]).collect { |k| Time.at(k.first).to_date }.uniq

      dates.should include(cassette_date)
    end
  end

	it "should raise a consistent exception on failed queries" do
		VCR.use_cassette('invalid_query') do
			expect {
	      Finance.execute_yql("INVALID QUERY")
	    }.to raise_error(Finance::QueryFailed)
	  end
	end

  it "should search for stock names and symbols matching given text" do
    VCR.use_cassette('search_for_stock') do
      @suggestions = Finance.search_for_stock('app')
      @suggestions.detect { |s| s['symbol'] == 'APPA' }.should be_true
      @suggestions.detect { |s| s['name'] == 'Applied Materials Inc.' }.should be_true
    end
  end

	it 'should correctly format a given nested hash into an openstruct object' do
		hash = {
      'Key' => 'value',
      'NestedKey' => {
        'NestedKey1' => 'value'
      }
		}

		openstruct = Finance.create_openstruct(hash)

    openstruct.key.should == 'value'
    openstruct.nested_key.nested_key1.should == 'value'
	end

end
