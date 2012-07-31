App.Router = Ember.Router.extend
  location: 'history'
  root: Ember.Route.extend
    index: Ember.Route.extend
      route: '/ember'
      connectOutlets: (router) ->
        router.get('applicationController').connectOutlet('stockList')
        router.get('stockListController').addStock('AAPL') # TODO add main
        router.get('stockListController').addStock('GOOG')