App.Stock = Em.Object.extend
  isLoaded: false

  symbol: (->
    @get 'id'
  ).property('id')

  load: ->
    jQuery.getJSON "/stock/#{@get('id')}/price_history.json", (data) =>
      @setProperties(data)
      @set 'isLoaded', true

  update_details: (details) ->
    new_details = details.table
    @setProperties(new_details)
    current_unix_timestamp = moment().unix()
    current_price = parseFloat(new_details['current_price'])
    data_point = [current_unix_timestamp, current_price]
    @get('price_history').live.push(data_point)

App.Stock.find = (stock_symbol) ->
  s = App.Stock.create({ id: stock_symbol, isMain: true })
  s.load()
  return s
