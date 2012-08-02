Handlebars.registerHelper 'dollars', (property) ->
  value = Ember.getPath(@, property)
  new Handlebars.SafeString('$ '+value)