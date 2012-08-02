App.Router = Ember.Router.extend
  enableLogging: true
  location: 'history'
  root: Ember.Route.extend
    index: Ember.Route.extend
      route: '/stock/:stock_id'
      connectOutlets: (router,stock) ->
        console.log 'connecting outlets'
        console.log stock
        router.get('applicationController').connectOutlet('graphOutlet','graph')
        router.get('applicationController').connectOutlet('stockListOutlet','stockList')
        router.get('stockListController').get('stocks').pushObject(stock)
