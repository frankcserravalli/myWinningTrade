App.StockListController = Em.Controller.extend
  stocks: []

  loadedStocks: (->
    @stocks.filterProperty('isLoaded', true)
  ).property('stocks.@each.isLoaded')

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
