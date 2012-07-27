require 'oauth'
require 'ostruct'
require 'rest_client'

class Finance
	class QueryFailed < Exception; end;

	cattr_accessor :credentials

	class << self
		def current_stock_details(symbol)
			details = stock_details_for_list([symbol])[symbol]
		end

		def stock_details_for_list(symbol_list)
			symbol_list = symbol_list.collect { |symbol| sanitize_symbol(symbol) }

			response = execute_yql("select Name, Symbol, Ask, AskRealtime, DaysRange, YearRange, Open, PreviousClose, Volume, DividendYield, EarningsShare, StockExchange, LastTradeTime, EPSEstimateCurrentYear, EPSEstimateNextYear, EPSEstimateNextQuarter, PERatio, TwoHundreddayMovingAverage, FiftydayMovingAverage, LastTradeDate
									 				    from yahoo.finance.quotes where symbol IN ('#{symbol_list.join(',')}')")['quote']

			response = [response] if symbol_list.length == 1

			details = response.collect do |quote|
				if quote['StockExchange']
					quote = create_openstruct(quote)
					quote.current_price = quote.ask_realtime || quote.ask
					quote.open ||= quote.previous_close
					quote.fifty_day_moving_average = quote.delete_field(:fiftyday_moving_average)
					quote.two_hundred_day_moving_average = quote.delete_field(:two_hundredday_moving_average)

					quote.currently_trading = (Date.strptime(quote.last_trade_date, '%m/%d/%Y') == Date.today)
					quote
				else
					nil
				end
			end

			return Hash[symbol_list.zip(details)]
		end

		def stock_price_history(symbol)
			symbol = sanitize_symbol(symbol)

			begin
				intraday_body = RestClient.get "http://chartapi.finance.yahoo.com/instrument/1.0/#{symbol.downcase}/chartdata;type=quote;range=1d/json"

				# Fix up Yahoo's messy JSON
				intraday_body.gsub!(/[\(\)]/, '')
				intraday_body.gsub!(/(\d+\.\d{4})"/, '\1')
				intraday_body.sub!('finance_charts_json_callback', '')

				return nil if intraday_body.include?('errorid')

				intraday_details = MultiJson.load(intraday_body)
			rescue Exception => e
				raise QueryFailed.new("Yahoo Intraday Request Failed: #{e}, HTTP response: #{intraday_body.to_s}")
			end

			stock_time_offset = intraday_details['meta']['gmtoffset'].to_i
			last_trading_day = Time.at(intraday_details['Timestamp']['max']+stock_time_offset-Time.now.gmt_offset)

			end_date = last_trading_day
			start_date = end_date - 6.months

			history = execute_yql("SELECT Close, Date FROM yahoo.finance.historicaldata WHERE symbol = '#{symbol}'
							 	 					   AND startDate = '#{ansi_date(start_date)}'
									 					 AND endDate   = '#{ansi_date(end_date-1.day)}'")

			stock_quote = execute_yql("SELECT Name, Symbol FROM yahoo.finance.quotes WHERE symbol='#{symbol}'")

			OpenStruct.new(
				symbol:
					stock_quote['quote']['Symbol'],
				name:
					stock_quote['quote']['Name'],
				price_history:
					historical_series = history['quote'].reverse.collect { |day| [Time.parse(day['Date']).to_i, day['Close'].to_f] } +
					intraday_details['series'].collect { |series| [series['Timestamp'], series['close'].to_f] }
			)
		end

		def search_for_stock(search_text)
			search_text.gsub!(/[^\w \.]/, '')

			response = RestClient.get "http://d.yimg.com/autoc.finance.yahoo.com/autoc?query=#{CGI::escape(search_text)}&callback=YAHOO.Finance.SymbolSuggest.ssCallback"
			response.gsub!(/[\(\)]/, '')
		  response.sub!('YAHOO.Finance.SymbolSuggest.ssCallback', '')

		  suggestions = MultiJson.load(response)
		  suggestions['ResultSet']['Result']
		end

		def sanitize_symbol(symbol)
			symbol.gsub(/[^\w]/, '')
		end

		def ansi_date(date)
			date.strftime('%Y-%m-%d')
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

	 	  start_time = Time.now.to_f
	    response = access_token.request(:get, '/v1/yql?' + query_string)

	    begin
	    	results = MultiJson.load(response.body)['query']['results']
	    	Rails.logger.debug "  YQL (#{((Time.now.to_f-start_time)*1000.0).round} ms / #{(response.body.length / 1024.0).round} KB): #{yql_query}" unless Rails.env.production?
	    rescue Exception => e
	    	raise QueryFailed.new("'#{yql_query}' (#{e}), response: #{response.body}")
	    end

		  results
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
