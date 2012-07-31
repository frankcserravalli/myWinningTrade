App.StockListController = Em.Controller.extend
  stocks: [{ name: 'hello'}, {name: 'stock2'}, {name: 'stock3'}]
  progress_value: 50
  deleteStock: (event) ->
    this_stock = event.view.get('context')
    @stocks.removeObject(this_stock)
