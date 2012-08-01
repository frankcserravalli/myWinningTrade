App.GraphController = Em.Controller.extend
  stocksBinding: 'App.router.stockListController.loadedStocks'

  stocksIsEmpty: ( ->
    @get('stocks').length == 0
  ).property('stocks')

  currentPeriod: 'historical'
  toggleCurrentPeriod: (event) ->
    period = event.target.dataset.period
    @set 'currentPeriod', period

  buttonHistoricalClasses: ( ->
    classes = 'btn'
    classes += ' btn-primary' if @get('currentPeriod') == 'historical'
    classes
  ).property('currentPeriod')

  buttonIntradayClasses: ( ->
    classes = 'btn'
    classes += ' btn-primary' if @get('currentPeriod') == 'intraday'
    classes
  ).property('currentPeriod')
