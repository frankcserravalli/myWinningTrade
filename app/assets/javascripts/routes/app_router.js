MyWinningTrade.Router = Ember.Router.extend({
  location: 'history',
  root: Ember.Route.extend({

    index: Ember.Route.extend({
      route: '/',
      connectOutlets: function(router) {
        router.get('applicationController').connectOutlet('loading')
      },
      enter: function(router) { console.log('loading stuff') },
      dashboard: Ember.Route.extend({
        route: '/dashboard',
        connectOutlets: function(router) {
          router.get('applicationController').connectOutlet('dashboard')
        }
      })
    }),

    stock: Ember.Route.extend({

    })

  })
});