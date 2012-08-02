App.Router = Ember.Router.extend
  location: 'history'
  root: Ember.Route.extend
    index: Ember.Route.extend
      route: '/stock/:stock_id'
      connectOutlets: (router,stock) ->
        router.get('stockListController').get('stocks').pushObject(stock)
        router.get('applicationController').connectOutlet('graphOutlet','graph')
        router.get('applicationController').connectOutlet('stockListOutlet','stockList')
