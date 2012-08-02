App.StockListController = Em.Controller.extend
  stocks: []

  lastUpdatedAt: null

  loadedStocks: (->
    @get('stocks').filterProperty('isLoaded', true)
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
    stock = event.view.get('context')
    @get('stocks').removeObject(stock)

  addStock: (symbol) ->
    new_stock = App.Stock.create({ id: symbol, isMain: @get('stocksIsEmpty') })
    new_stock.load()
    @get('stocks').pushObject(new_stock)

  amendSubscriptions: ->
    window.finance.unsubscribe @
    loaded_stocks_symbols = _.pluck(@get('loadedStocks'),'id')
    window.finance.subscribe @, loaded_stocks_symbols.join(','), (payload) =>
      @get('stocks').forEach (stock) ->
        stock_details = payload[stock.get('symbol')]
        stock.update_details(stock_details)
      @set 'lastUpdatedAt', moment().unix()

