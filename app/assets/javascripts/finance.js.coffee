class @Finance
  constructor: (@tick_interval) ->

  stocks: []
  subscriptions: {}

  subscribe: (reference, stock_symbols_list, callback) ->
    # accept a single string or comma separated list of stock symbols
    stock_symbols = stock_symbols_list.split(',') # TODO sanitize with regex

    # enforce uppercasing of symbol
    stock_symbols = _.map stock_symbols, (symbol) ->
      symbol.toUpperCase()

    # save subscription symbols and callback
    @subscriptions[reference] = {
      stock_symbols: stock_symbols,
      data_received: callback
    }

    # update stock set to include any new stocks
    @stocks = _.union(@stocks, stock_symbols)

  unsubscribe: (reference) ->
    # remove subscription
    delete @subscriptions[reference]
    # TODO remove stocks that are no longer in unique set

  # TICKER:
  start_ticking: ->
    @tick()
    @ticker = setInterval @tick, @tick_interval

  stop_ticking: ->
    console.log 'tick stop'
    clearInterval(@ticker)

  tick: ->
    console.log 'tick'
    # TODO
    # stock SET = ...
    # ajax request with stock array
    # response:
    # - stock not found, unsubscribe?
    # - for each stock response, run callback



  $(->
    window.f = new Finance(5000)
    # f.start_ticking()
  )

