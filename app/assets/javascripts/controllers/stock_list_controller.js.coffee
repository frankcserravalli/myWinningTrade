App.StockListController = Em.Controller.extend
  stocks: []

  lastUpdatedAt: null

  loadedStocks: (->
    @stocks.filterProperty('isLoaded', true)
  ).property('stocks.@each.isLoaded')

  loadedStocksDidChange: (->
    @amendSubscriptions()
  ).observes('loadedStocks.@each')

  stocksIsEmpty: ( ->
    @get('stocks').length == 0
  ).property('stocks.@each')

  loadedStocksIsEmpty: ( ->
    @get('loadedStocks').length == 0
  ).property('loadedStocks')

  deleteStock: (event) ->
    stock = event.view.get('context') # TODO change context?
    stock.unsubscribe_from_live_updates()
    @stocks.removeObject(stock)

  addStock: (symbol) ->
    new_stock = App.Stock.create({ symbol: symbol, isMain: @get('stocksIsEmpty') })
    new_stock.load()
    @stocks.pushObject(new_stock)

  amendSubscriptions: ->
    window.finance.unsubscribe @
    loaded_stocks_symbols = _.pluck(@get('loadedStocks'),'symbol')
    window.finance.subscribe @, loaded_stocks_symbols.join(','), (payload) =>
      @get('stocks').forEach (stock) ->
        stock_details = payload[stock.symbol]
        stock.update_details(stock_details)
      @set 'lastUpdatedAt', moment().unix()

