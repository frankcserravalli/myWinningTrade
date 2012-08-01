App.Stock = Em.Object.extend
  isLoaded: false
  load: ->
    jQuery.getJSON "/stock/#{@get('symbol')}/price_history.json", (data) =>
      @setProperties(data)
      @set 'isLoaded', true
      #@set 'live', data.quotes.live
      #@subscribe_to_live_updates()

  update_details: (details) ->
    new_details = details.table
    @setProperties(new_details)

    current_unix_timestamp = moment().unix()
    current_price = parseFloat(new_details['current_price'])
    data_point = [current_unix_timestamp, current_price]
    @get('price_history').live.push(data_point)

  unsubscribe_from_live_updates: ->
    window.finance.unsubscribe @
