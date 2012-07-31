App.StockListView = Ember.View.extend
  templateName: 'stock_list'
  didInsertElement: ->
    text_field = $('.autocomplete',@$())
    text_field.autocomplete({
      source: ['a','b','c']
      select: (event, ui) ->
        alert(ui.item.symbol)
    }).data("autocomplete")._renderItem = (ul, item) ->
      $("<li></li>").data('item.autocomplete', item).append("<a><span class='tip'>#{item.exchDisp}</span> #{item.symbol} <br /><small>#{item.name}</small></a>").appendTo(ul)
