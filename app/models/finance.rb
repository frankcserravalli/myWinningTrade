require 'oauth'

class Finance
	cattr_accessor :credentials

	def current_stock_details(symbol)
		#execute_yql("select * from http://www.datatables.org/yahoo/finance/yahoo.finance.quotes where symbol='#{symbol}'")
		execute_yql("show tables")
	end

	def execute_yql(query)
		consumer = OAuth::Consumer.new(self.credentials['consumer_key'], self.credentials['consumer_secret'], site: 'http://query.yahooapis.com')
		access_token = OAuth::AccessToken.new(consumer)

		response = access_token.request(:get, "/v1/yql?q=#{OAuth::Helper.escape(query)}&format=json")
		JSON.parse(response.body)
	end
end
