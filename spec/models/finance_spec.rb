require 'spec_helper'

describe "Finance" do
  before do
    @api = Finance
  end

	it "should return the details of a given stock" do
		VCR.use_cassette('quote') do
			quote = @api.current_stock_details('AAPL')

			quote.symbol.should == 'AAPL'
			quote.name.should == 'Apple Inc.'

			[:name, :symbol, :ask, :ask_realtime, :days_range, :year_range, :open, :previous_close, :volume, :dividend_yield, :earnings_share, :stock_exchange, :last_trade_time, :current_price, :eps_estimate_current_year, :eps_estimate_next_year, :eps_estimate_next_quarter].each do |key|
				quote.respond_to?(key).should be_true
			end
		end
	end

  it "should return the price of a stock every week day for the past 6 months" do
    cassette_date = Time.at(1343052000).to_date

    VCR.use_cassette('stock_price_history', :record => :new_episodes) do
      @history = @api.stock_price_history('AAPL')
      @history.symbol.should == 'AAPL'
      @history.name.should == 'Apple Inc.'

      dates = @history.price_history.collect { |k| Time.at(k.first).to_date }.uniq

      dates.should include(cassette_date)
      dates.should include(cassette_date - 6.months)
    end
  end

	it "should raise a consistent exception on failed queries" do
		VCR.use_cassette('invalid_query') do
			expect {
	      Finance.execute_yql("INVALID QUERY")
	    }.to raise_error(Finance::QueryFailed)
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
