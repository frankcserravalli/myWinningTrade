class @Finance
  constructor: (@tick_interval_ms) ->
    @subscriptions = {}
    @stocks = []
    @references = [] # just a bit of sugar

  subscribe: (reference, stock_symbols_list = '', callback) ->

    # accept a single string or comma separated list of stock symbols
    stock_symbols = stock_symbols_list.split(',')

    # strip non alphanumeric characters and uppercase the symbols
    stock_symbols = _.map stock_symbols, (symbol) ->
      symbol.replace(/[^a-zA-Z0-9\.\-]+/g,'').toUpperCase()

    # save subscription reference
    @references = _.union(@references, reference)

    # save subscription symbols and callback
    @subscriptions[reference] = {
      stock_symbols: stock_symbols,
      callback: callback
    }

    # update stock set to include any new stocks
    @stocks = _.union(@stocks, stock_symbols)

  unsubscribe: (reference) ->
    # find subscription and exit if not found
    subscription = @subscriptions[reference]
    return false unless subscription

    # store this subscription's stock_symbols for later consideration
    potential_removals = subscription.stock_symbols

    # remove subscription reference
    @references = _.without(@references, reference)

    # remove subscription
    delete @subscriptions[reference]

    # recalculate stock list since this unsubscribing object may contain some unique stocks
    # i think this reads better than using double-break loops for potentially removable stocks
    # if it's really a performance issue, then it can be rewritten
    @stocks = _.uniq(_.flatten(_.pluck(_.values(@subscriptions),'stock_symbols')))

  start_ticking: ->
    # run tick immediately, and set a regular interval
    @tick()
    @ticker = setInterval ( =>
      @tick()
    ), @tick_interval_ms

  stop_ticking: ->
    clearInterval(@ticker)
    @ticker = null

  tick: ->
    # do nothing if there are no subscriptions
    return if _.isEmpty(@subscriptions)

    query_string = $.param({ stocks: @stocks })

    $.ajax '/stock/details?' + query_string,
      type: 'GET'
      dataType: 'JSON'
      success: (payload, textStatus, jqXHR) =>
        @latest_payload = payload
        @run_callbacks()

  run_callbacks: ->
    payload = @latest_payload
    _.each @references, (reference) =>
      subscription = @subscriptions[reference]
      required_stock_symbols = subscription.stock_symbols

      required_data_is_available = _.all required_stock_symbols, (stock_symbol) ->
        _.has payload, stock_symbol

      if required_data_is_available
        cherry_picked_payload = {}
        _.each subscription.stock_symbols, (stock_symbol) ->
          cherry_picked_payload[stock_symbol] = payload[stock_symbol]
        subscription.callback cherry_picked_payload


$(->
  window.finance = new Finance(5000)
  finance.start_ticking()
)
