App.GraphController = Em.Controller.extend
  stocksBinding: 'App.router.stockListController.loadedStocks'
  lastUpdatedAtBinding: 'App.router.stockListController.lastUpdatedAt'

  stocksIsEmpty: ( ->
    @get('stocks').length == 0
  ).property('stocks')

  currentPeriod: 'historical'
  toggleCurrentPeriod: (event) ->
    @set 'currentPeriod', event.target.dataset.period

  buttonHistoricalClasses: ( ->
    classes = 'btn btn-large'
    classes += ' btn-primary' if @get('currentPeriod') == 'historical'
    classes
  ).property('currentPeriod')

  buttonLiveClasses: ( ->
    classes = 'btn btn-large'
    classes += ' btn-primary' if @get('currentPeriod') == 'live'
    classes
  ).property('currentPeriod')
