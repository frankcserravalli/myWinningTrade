App.Stock = Em.Object.extend
  isLoaded: false
  load: ->
    jQuery.getJSON "/stock/#{@get('symbol')}/price_history.json", (data) =>
      @setProperties(data)
      @set 'isLoaded', true
      #@set 'live', data.quotes.live
      @subscribe_to_live_updates()

  subscribe_to_live_updates: ->
    window.finance.subscribe @, @get('symbol'), (payload) =>
      console.log payload[@get('symbol')]
      stock_details = payload[@get('symbol')].table
      current_unix_timestamp = moment().unix()
      current_price = parseFloat(stock_details['current_price'])
      data_point = [current_unix_timestamp, current_price]
      console.log 'ticking for ' + @get('symbol')
      # add new 'quote'
      # update graph

  unsubscribe_from_live_updates: ->
    window.finance.unsubscribe @
