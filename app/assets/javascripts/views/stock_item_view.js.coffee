App.StockItemView = Em.View.extend
  classNameBindings: ['context.error:alert-error']
  templateName: 'stock_item'
  tagName: 'li'

  removeStock: (event) ->
    stock = event.context
    stock_list_controller = @get('controller')
    stock_list_controller.removeStock(stock)

  willDestroyElement: ->
    clone = @$().clone()
    clone.removeClass('ember-view')
    @$().parent().append(clone)
    clone.fadeOut()
