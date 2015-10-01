require 'oauth'
require 'ostruct'
require 'rest_client'
require 'yahoo_finanza'

class Array
  def uniq_by(&blk)
    transforms = []
    select do |el|
      should_keep = !transforms.include?(t = blk[el])
      transforms << t
      should_keep
    end
  end
end

class Finance
  class QueryFailed < Exception; end
  L2N = { 'M' => 1_000_000, 'B' => 1_000_000_000 }.freeze

  cattr_accessor :credentials

  class << self
    def current_stock_details(symbol, for_iphone = nil)
      if for_iphone
        stock_details_for_list([symbol])
      else
        stock_details_for_list([symbol])
      end
    end

    # Here we are asking Yahoo to return us information on multiple stocks,
    # where symbol_list represents those multiple stocks
    def stock_details_for_list(symbol_list)
      return nil if symbol_list.empty?
      clean_quotes(YahooFinanza::MultiQuoteWorker.new(symbol_list).run)
    end

    def stock_details_for_symbol(symbol)
      YahooFinanza::SingleQuoteWorker.new(symbol).run
    end

    def grab_alpha_or_beta
      csv = RestClient.get "download.finance.yahoo.com/d/quotes.csv", {:params => {:s => "SPY", :f => 'w0'}}

      returned_info = CSV.parse(csv).join()

      returned_info = returned_info.split(" ") - ["-"]

      price_from_year_ago = returned_info[0].to_f

      price_now = returned_info[1].to_f

      beta = price_now / price_from_year_ago
      # For alpha use this     number_to_percentage((Finance.grab_alpha_or_beta("alpha") * 100), precision: 2)
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

      history = MarketBeat.quotes(symbol, ansi_date(start_date), ansi_date(end_date))

      stock_quote = stock_details_for_symbol(symbol)

      OpenStruct.new(
        symbol:
          stock_quote.symbol,
        name:
          stock_quote.name,
        currently_trading:
          stock_quote.currently_trading,
        current_price:
          stock_quote.current_price,
        point_change:
          stock_quote.point_change,
        percent_change:
          stock_quote.percent_change,
        trend_direction:
          stock_quote.trend_direction,
        price_history: {
          historical: history.reverse.collect { |day| [day[:date].to_time.to_i, day[:close].to_f] },
          live: intraday_details['series'].collect { |series| [series['Timestamp'].to_i/1.minute*1.minute, series['close'].to_f] }.uniq_by(&:first)
        }
      )
    end

    def search_for_stock(search_text)
      search_text.gsub!(/[^\w \.]/, '')

      response = RestClient.get "http://d.yimg.com/autoc.finance.yahoo.com/autoc?query=#{CGI::escape(search_text)}&callback=YAHOO.Finance.SymbolSuggest.ssCallback"

      response.gsub!(/[\(\)]/, '')

      response.sub!('YAHOO.Finance.SymbolSuggest.ssCallback', '')

      suggestions = MultiJson.load(response)

      suggestions['ResultSet']['Result'].select { |result| result['type'].to_s == 'S' }
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

        raise
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

    private

    def clean_quotes quotes
      quotes.reject { |quote| quote.name == nil }
    end
  end
end
