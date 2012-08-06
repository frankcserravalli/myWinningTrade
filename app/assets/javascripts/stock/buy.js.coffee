$ ->
  $('#buy_volume').on 'keyup change', (event) ->
    volume = parseFloat($(event.target).val().replace('$', ''));

    if isNaN(volume) || volume <= 0
      $("#buy_price_calculation, #cash_buy_calculation").html("Volume must be greater than 0")
    else
      cost_to_purchase = parseFloat($('#buy_price').html().replace('$', ''))*volume
      $('#buy_price_calculation').html('$ '+ cost_to_purchase.formatMoney(2, '.', ','))

      cash_after_purchase = parseFloat($("#current_cash").html().replace(/[$,]/g, '')) - cost_to_purchase
      $("#cash_buy_calculation").html('$'+cash_after_purchase.formatMoney(2, '.', ','));

      if cash_after_purchase < 0.0
        $("#cash_buy_calculation").addClass('negative')
      else
        $("#cash_buy_calculation").removeClass('negative')
