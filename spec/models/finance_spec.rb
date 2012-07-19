require 'spec_helper'

describe "Finance" do
	it "should return the details of a given stock" do
		@api = Finance.new
		quote = @api.current_stock_details('AAPL')

		quote.symbol.should == 'AAPL'
		quote.name.should == 'Apple Inc.'
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
