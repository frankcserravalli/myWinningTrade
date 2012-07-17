require 'spec_helper'

describe "Finance" do
	it "should return the details of a given stock" do
		@api = Finance.new

		puts @api.current_stock_details('AAPL').inspect
	end
end
