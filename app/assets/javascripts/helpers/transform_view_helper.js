// from https://gist.github.com/2588802
Ember.HandlebarsTransformView = Ember.View.extend(Ember._Metamorph, {
  rawValue: null,
  transformFunc: null,

  value: function(){
    var rawValue = this.get('rawValue'),
        transformFunc = this.get('transformFunc');
    return transformFunc(rawValue);
  }.property('rawValue', 'transformFunc').cacheable(),

  render: function(buffer) {
    var value = this.get('value');
    if (value) { buffer.push(value); }
  },

  needsRerender: function() {
    if (this.get("state") !== "destroyed") {
      this.rerender();
    }
  }.observes('value')
});

Ember.HandlebarsTransformView.helper = function(context, property, transformFunc, options) {
  options.hash = {
    rawValueBinding: property,
    transformFunc:   transformFunc
  };
  return Ember.Handlebars.ViewHelper.helper(context, Ember.HandlebarsTransformView, options);
};
