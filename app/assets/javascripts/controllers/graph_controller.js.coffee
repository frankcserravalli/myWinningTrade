App.GraphController = Em.Controller.extend
  stocksBinding: 'App.router.stockListController.loadedStocks'

  stocksIsEmpty: ( ->
    @get('stocks').length == 0
  ).property('stocks')

  currentPeriod: 'historical'
  toggleCurrentPeriod: (event) ->
    if event.target.dataset.period == 'intraday'
      @set 'currentPeriod', 'live'
    else
      @set 'currentPeriod', 'historical'

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
