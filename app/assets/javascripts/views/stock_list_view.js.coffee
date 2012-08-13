App.StockListView = Ember.View.extend
  templateName: 'stock_list'
  classNames: 'stock-compare-wrapper'
  didInsertElement: ->
    text_field = $('.autocomplete',@$())
    text_field.autocomplete({
      source: '/stock/search'
      select: (event, ui) =>
        @getPath('controller').addStock(ui.item.symbol)
    }).data("autocomplete")._renderItem = (ul, item) ->
      $("<li></li>").data('item.autocomplete', item).append("<a><span class='tip'>#{item.exchDisp}</span> #{item.symbol} <br /><small>#{item.name}</small></a>").appendTo(ul)
