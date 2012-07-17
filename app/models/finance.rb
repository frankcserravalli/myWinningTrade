require 'oauth'

class Finance
	cattr_accessor :credentials

	def current_stock_details(symbol)
		execute_yql("select * from yahoo.finance.quotes where symbol='#{symbol}'")
		#execute_yql("show tables")
	end

	def execute_yql(yql_query)
		consumer = OAuth::Consumer.new(self.credentials['consumer_key'], self.credentials['consumer_secret'], site: 'http://query.yahooapis.com')
		access_token = OAuth::AccessToken.new(consumer)

		params = {
		  q: yql_query,
		  env: 'http://datatables.org/alltables.env',
		  format: 'json',
		  diagnostics: false
		}

        # merge params into escaped query string
		query_string = params.map{ |k,v| "#{k}=#{OAuth::Helper.escape(v)}" }.join('&')

		response = access_token.request(:get, '/v1/yql?' + query_string)
		return JSON.parse(response.body)
	end
end
