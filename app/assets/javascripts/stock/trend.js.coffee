$ ->
  # live update each stock trend element
  $('.stock-trend').each (i,e) ->
    symbol = $(e).data('stock-symbol')
    finance.subscribe e, symbol, (payload) =>

      stock_details = payload[symbol].table
      # TODO more here...
      $('.current-price',e).html('$ ' + stock_details.current_price)

  $('#buy_volume').on 'keyup', (event) ->
    volume = parseFloat($(event.target).val().replace('$', ''))

    if isNaN(volume) || volume <= 0
      $("#buy_price_calculation").html("Enter the number of shares to buy")
    else
      $('#buy_price_calculation').html('$ '+ (parseFloat($('#buy_price').html().replace('$', ''))*volume).formatMoney(2, '.', ','))
