$ ->
  # live update each stock trend element
  $('.stock-trend').each (i,e) ->
    symbol = $(e).data('stock-symbol')
    finance.subscribe e, symbol, (payload) =>
      stock_details = payload[symbol].table
      # TODO more here...
      $('.current-price',e).html(stock_details.current_price)
