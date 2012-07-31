App.StockListController = Em.Controller.extend
  stocks: []

  loadedStocks: (->
    @stocks.filterProperty('isLoaded', true)
  ).property('stocks.@each.isLoaded')

  progress_value: 50
  deleteStock: (event) ->
    this_stock = event.view.get('context')
    @stocks.removeObject(this_stock)
  addStock: (symbol) ->
    new_stock = App.Stock.create({ symbol: symbol, isMain: !@stocks.length })
    new_stock.load()
    @stocks.pushObject(new_stock)
