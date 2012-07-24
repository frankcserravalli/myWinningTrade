class @Finance
  constructor: (@tick_interval_ms) ->
    @subscriptions = {}
    @stocks = []
    @references = [] # just a bit of sugar

  subscribe: (reference, stock_symbols_list = '', callback) ->
    # accept a single string or comma separated list of stock symbols
    stock_symbols = stock_symbols_list.split(',') # TODO sanitize with regex

    # strip non alphanumeric characters and uppercase symbol
    stock_symbols = _.map stock_symbols, (symbol) ->
      symbol.replace(/\W+/g,'').toUpperCase()

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
    @ticker = setInterval @tick, @tick_interval_ms

  stop_ticking: ->
    clearInterval(@ticker)
    @ticker = null

  tick: ->
    # TODO seems my understanding of this is not compatible
    # with how the controller is currently written
    #$.ajax '/...',
    #  type: 'GET',
    #  dataType: 'json',
    #  data: @stocks,
    #  success: (data, textStatus, jqXHR) =>
        # payload = do_whatever_transforms(data['stocks'])
    #    @latest_payload = payload
    #    @runCallbacks()

    # alternatively, when testing,
    # @latest_stock_data = 'mockmockmock'
    @runCallbacks()

  run_callbacks: ->
    _.each @references, (reference) =>
      # prepare (pluck) stock data or send thru all data
      subscription = @subscriptions[reference]
      subscription.callback('[stocks]')

  receive_stock_data: (stock_data) ->
    # ~ for each stock's value:
    # ~ if stock is nil, (is it reasonable to ever expect that except in server failure?)
    # ~ do what?
    # ~ remove any callbacks using it?
    # ~ repair the array?
    # ~ just ignore those callbacks?
    # ~ send null through?


  $(->
    window.f = new Finance(5000)
    # f.start_ticking()
  )