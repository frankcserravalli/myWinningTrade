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
    _.each @references, (reference) =>
      cherry_picked_payload = @latest_payload # TODO cherry pick
      subscription = @subscriptions[reference]
      subscription.callback(cherry_picked_payload)

  receive_stock_data: (stock_data) ->
    # ~ for each stock's value:
    # ~ if stock is nil, (is it reasonable to ever expect that except in server failure?)
    # ~ do what?
    # ~ remove any callbacks using it?
    # ~ repair the array?
    # ~ just ignore those callbacks?
    # ~ send null through?

$(->
  window.finance = new Finance(5000)
  finance.start_ticking()
)
