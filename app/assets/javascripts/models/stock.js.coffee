App.Stock = Em.Object.extend
  isLoaded: false

  symbol: (->
    @get 'id'
  ).property('id')

  load: (controller) ->
    jQuery.getJSON "/stock/#{@get('id')}/price_history.json", (data) =>
      @setProperties(data)
      console.log data
      @set 'isLoaded', true
    .error =>
      @set 'error', true
      controller.removeStock(@)

  update_details: (details, unix_timestamp) ->
    new_details = details.table
    @setProperties(new_details)
    current_price = parseFloat(new_details['current_price'])
    data_point = [unix_timestamp, current_price]
    @get('price_history').live.push(data_point)

  priceHistoryDidChange: ( ->
    console.log "new history for #{@get 'symbol'}"
  ).observes('price_history')

App.Stock.find = (stock_symbol) ->
  s = App.Stock.create({ id: stock_symbol, isMain: true })
  s.load()
  return s
