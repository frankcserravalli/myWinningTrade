App.GraphController = Em.Controller.extend
  stocksBinding: 'App.router.stockListController.loadedStocks'

  stocksIsEmpty: ( ->
    @get('stocks').length == 0
  ).property('stocks')

  currentPeriod: 'historical'
  toggleCurrentPeriod: (event) ->
    @set 'currentPeriod', event.target.dataset.period

  buttonHistoricalClasses: ( ->
    classes = 'btn'
    classes += ' btn-primary' if @get('currentPeriod') == 'historical'
    classes
  ).property('currentPeriod')

  buttonLiveClasses: ( ->
    classes = 'btn'
    classes += ' btn-primary' if @get('currentPeriod') == 'live'
    classes
  ).property('currentPeriod')
