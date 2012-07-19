require 'spec_helper'

describe "Finance" do
	it "should return the details of a given stock" do
		VCR.use_cassette('quote') do
			@api = Finance.new
			quote = @api.current_stock_details('AAPL')

			quote.symbol.should == 'AAPL'
			quote.name.should == 'Apple Inc.'

			[:name, :symbol, :ask, :ask_realtime, :days_range, :year_range, :open, :previous_close, :volume, :dividend_yield, :earnings_share, :stock_exchange, :last_trade_time, :current_price].each do |key|
				quote.respond_to?(key).should be_true
			end
		end
	end

	it "should raise a consistent exception on failed requests" do
		VCR.use_cassette('invalid_query') do
			expect {
	      Finance.new.execute_yql("INVALID QUERY")
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
