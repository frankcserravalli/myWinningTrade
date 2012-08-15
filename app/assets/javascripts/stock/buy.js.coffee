#{User.last.inspect}

$ ->
  $('#buy_volume').on 'keyup change', (event) ->
    volume = parseFloat($(event.target).val().replace('$', ''));

    if isNaN(volume) || volume <= 0
      $("#buy_price_calculation, #cash_buy_calculation").html("Volume must be greater than 0")
      $("#cash_buy_calculation").addClass('invalid')
    else
      cost_to_purchase = parseFloat($('#buy_price').html().replace('$', ''))*volume + MyWinningTrade.transaction_fee
      $('#buy_price_calculation').html('$'+ cost_to_purchase.formatMoney(2, '.', ','))

      cash_after_purchase = parseFloat($("#current_cash").html().replace(/[$,]/g, '')) - cost_to_purchase
      $("#cash_buy_calculation").html('$'+cash_after_purchase.formatMoney(2, '.', ','));

      if cash_after_purchase < 0.0
        $("#cash_buy_calculation").addClass('invalid')
      else
        $("#cash_buy_calculation").removeClass('invalid')


  $('#buy_form').on 'submit', (event) ->
    if $(event.target).find('.invalid').size() > 0
      alert("You do not have sufficient funds to buy that number of shares.")
      event.preventDefault()

