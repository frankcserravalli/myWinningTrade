App.Router = Ember.Router.extend
  location: 'history'
  root: Ember.Route.extend
    index: Ember.Route.extend
      route: '/stock/:stock_id'
      connectOutlets: (router,stock) ->
        stock.setProperties(App.payload)
        router.get('applicationController').set('stock',stock)
        router.get('stockListController').get('stocks').pushObject(stock)
