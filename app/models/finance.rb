require 'oauth'
require 'ostruct'

class Finance
	cattr_accessor :credentials

	def current_stock_details(symbol)
		execute_yql("select * from yahoo.finance.quotes where symbol='#{symbol}'").quote
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

    results = MultiJson.load(response.body)['query']['results']
	  return self.class.create_openstruct(results)
	end

	def self.create_openstruct(value)
		# recursively builds an openstruct for a given hash
	  case value
	    when Hash
	      OpenStruct.new(Hash[value.map { |k, v| [k.to_s.underscore, create_openstruct(v)] }])
	    else
	      value
	  end
	end

end
