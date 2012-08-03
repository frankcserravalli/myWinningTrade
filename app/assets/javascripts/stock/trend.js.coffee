$ ->
  # live update each stock trend element
  $('.stock-trend').each (i,e) ->
    symbol = $(e).data('stock-symbol')
    finance.subscribe e, symbol, (payload) =>

      stock_details = payload[symbol].table
      # TODO more here...
      $('.current-price',e).html('$' + stock_details.current_price)

  $('#buy_volume').on 'keyup', (event) ->
    volume = parseFloat($(event.target).val().replace('$', ''));

    if isNaN(volume) || volume <= 0
      $("#buy_price_calculation, #cash_after_purchase_calculation").html("Volume must be greater than 0")
    else
      cost_to_purchase = parseFloat($('#buy_price').html().replace('$', ''))*volume
      $('#buy_price_calculation').html('$ '+ cost_to_purchase.formatMoney(2, '.', ','))

      cash_after_purchase = parseFloat($("#current_cash").html().replace(/[$,]/g, '')) - cost_to_purchase
      $("#cash_after_purchase_calculation").html('$'+cash_after_purchase.formatMoney(2, '.', ','));

      if cash_after_purchase < 0.0
        $("#cash_after_purchase_calculation").addClass('negative')
      else
        $("#cash_after_purchase_calculation").removeClass('negative')
