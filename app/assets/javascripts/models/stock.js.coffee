App.Stock = Em.Object.extend
  isLoaded: false
  load: ->
    jQuery.getJSON "/stock/#{@get('symbol')}/price_history.json", (data) =>
      @setProperties(data)
      @set 'isLoaded', true
