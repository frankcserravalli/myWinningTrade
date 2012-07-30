describe 'Finance', ->
  finance = null
  beforeEach ->
    finance = new Finance(0)

  describe 'subscribing', ->
    it 'accepts subscriptions based on a given reference key', ->
      expect(finance.subscriptions['ref']).not.toBeDefined
      finance.subscribe 'ref', 'GOOG'
      expect(finance.subscriptions['ref']).toBeDefined

    it 'adds to the references array on subscription', ->
      expect(finance.references).not.toContain 'ref'
      finance.subscribe 'ref', 'GOOG'
      expect(finance.references).toContain 'ref'

    it 'accepts a single stock symbol string for subscribing', ->
      finance.subscribe 'ref', 'GOOG'
      stock_symbols = finance.subscriptions['ref'].stock_symbols
      expect(stock_symbols).toContain 'GOOG'

    it 'accepts a comma-separated string list of stock symbols for subscribing', ->
      finance.subscribe 'ref', 'GOOG,AAPL'
      stock_symbols = finance.subscriptions['ref'].stock_symbols

      # would love to find a terser way to express the following
      # but can't be assured of the array order, and would rather
      # not implicate a sort function (explicitly or implicitly)
      expect(stock_symbols.length).toEqual 2
      expect(stock_symbols).toContain 'GOOG'
      expect(stock_symbols).toContain 'AAPL'

    it 'maintains a unique stock set when adding a subscription for duplicate stocks', ->
      finance.subscribe 'ref1', 'GOOG'
      expect(finance.stocks).toEqual ['GOOG']

      finance.subscribe 'ref2', 'GOOG, AAPL'
      expect(finance.stocks.length).toEqual 2
      expect(finance.stocks).toContain 'GOOG'
      expect(finance.stocks).toContain 'AAPL'

    describe 'normalizing stock symbol to chomped alphanumeric/caps only', ->
      it 'normalizes a single stock symbol', ->
        finance.subscribe 'ref', ' goog --/""  '
        subscription = finance.subscriptions['ref']
        expect(subscription.stock_symbols).toEqual ['GOOG']
      
      it 'allows a "." in stock symbol', ->
        finance.subscribe 'ref', 'abc.de'
        subscription = finance.subscriptions['ref']
        expect(subscription.stock_symbols).toEqual ['ABC.DE']

      it 'normalizes a comma-separated string list of stock symbols', ->
        finance.subscribe 'ref', '  goog  ,  aapl--/""'
        stock_symbols = finance.subscriptions['ref'].stock_symbols
        expect(stock_symbols.length).toEqual 2
        expect(stock_symbols).toContain 'GOOG'
        expect(stock_symbols).toContain 'AAPL'

  describe 'unsubscribing', ->
    it 'removes subscriptions based on a given reference key', ->
      finance.subscribe 'ref', 'GOOG'
      expect(finance.subscriptions['ref']).toBeDefined
      finance.unsubscribe 'ref'
      expect(finance.subscriptions['ref']).not.toBeDefined

    it 'doesnt completely break when unsubscribing with a non-existant reference', ->
      expect(finance.subscriptions).toEqual []
      finance.subscribe('GOOG')
      expect(finance.unsubscribe('GOOG')).toBeTruthy
      expect(finance.unsubscribe('bananas')).toBeFalsy

    it 'removes the reference from the set on unsubscribing', ->
      finance.subscribe 'ref', 'GOOG'
      expect(finance.references).toContain 'ref'
      finance.unsubscribe 'ref'
      expect(finance.references).not.toContain 'ref'

    it 'removes a stock from the set when successfully unsubscribing', ->
      finance.subscribe 'ref', 'GOOG'
      expect(finance.stocks).toContain 'GOOG'
      finance.unsubscribe 'ref'
      expect(finance.stocks).not.toContain 'GOOG'

    it 'only removes a stock from the unique set if no remaining subscriptions require it', ->
      finance.subscribe 'ref1', 'GOOG, AAPL, COOL'

      finance.subscribe 'ref2', 'AAPL, YUM, CAKE'
      expect(finance.stocks).toContain 'AAPL'
      expect(finance.stocks).toContain 'YUM'
      expect(finance.stocks).toContain 'CAKE'

      finance.unsubscribe 'ref2'
      expect(finance.stocks).toContain 'AAPL'
      expect(finance.stocks).not.toContain 'YUM'
      expect(finance.stocks).not.toContain 'CAKE'

  it 'applies callbacks (rename me)', ->
    # rather than doing this by demonstration, do this by theory
    # you can make a spy and check that it receives 'call'

    response = null

    prepared_payload = { 'GOOG': 'secret' }

    finance.latest_payload = prepared_payload
    expect(response).toEqual null

    finance.subscribe 'ref', 'GOOG', (payload) ->
      response = payload
    finance.run_callbacks()
    expect(response).toEqual prepared_payload