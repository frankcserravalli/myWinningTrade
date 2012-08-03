Handlebars.registerHelper 'dollars', (property, opts) ->
  transformFunc = (value) ->
    '$ ' + value
  return Ember.HandlebarsTransformView.helper(@, property, transformFunc, opts)
