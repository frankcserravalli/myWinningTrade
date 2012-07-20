require 'oauth'
require 'ostruct'

class Finance
	class QueryFailed < Exception; end;

	cattr_accessor :credentials

	class << self
		def current_stock_details(symbol)
			symbol.gsub!(/[^\w]/, '')

			execute_yql("select Name, Symbol, Ask, AskRealtime, DaysRange, YearRange, Open, PreviousClose, Volume, DividendYield, EarningsShare, StockExchange, LastTradeTime, EPSEstimateCurrentYear, EPSEstimateNextYear, EPSEstimateNextQuarter
									 from yahoo.finance.quotes where symbol='#{symbol}'").quote.tap do |quote|

				return nil unless quote.stock_exchange

				quote.current_price = quote.ask_realtime || quote.ask
				quote.open ||= quote.previous_close
			end
		end

		def execute_yql(yql_query)
			self.reload_credentials unless self.credentials

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

	    begin
	    	results = MultiJson.load(response.body)['query']['results']
	    rescue Exception => e
	    	raise QueryFailed.new("'#{yql_query}' (#{e}), response: #{response.body}")
	    end

		  return self.create_openstruct(results)
		end

		def reload_credentials
			self.credentials = YAML::load_file(Rails.root.join('config', 'finance.yml'))[Rails.env.to_s]
			raise "No finance API credentials specified for environment #{Rails.env}" unless self.credentials
		end

		def create_openstruct(value)
			# recursively builds an openstruct for a given hash
		  case value
		    when Hash
		      OpenStruct.new(Hash[value.map { |k, v| [k.to_s.underscore, create_openstruct(v)] }])
		    else
		      value
		  end
		end
	end
end
