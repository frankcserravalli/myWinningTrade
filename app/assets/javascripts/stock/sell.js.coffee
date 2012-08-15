$ ->
  $('#sell_volume').on 'keyup change', (event) ->
    volume = parseFloat($(event.target).val().replace('$', ''));

    if isNaN(volume) || volume <= 0
      $("#sell_price_calculation, #cash_sell_calculation, #shares_remaining").html("You must sell at least 1 share")
      $("#shares_remaining").addClass('invalid')
    else
      cash_from_sale = parseFloat($('#sell_price').html().replace('$', ''))*volume
      $('#sell_price_calculation').html('$'+ cash_from_sale.formatMoney(2, '.', ','))

      cash_after_sale = parseFloat($("#current_cash").html().replace(/[$,]/g, '')) + cash_from_sale
      $("#cash_sell_calculation").html('$'+cash_after_sale.formatMoney(2, '.', ','));

      current_shares = parseFloat($("#current_shares").html().replace(/[^\d]/g, ''))

      shares_after_sale = current_shares - volume
      $("#shares_remaining").html(shares_after_sale)

      if shares_after_sale < 0.0
        $("#shares_remaining").addClass('invalid')
      else
        $("#shares_remaining").removeClass('invalid')

  $('#sell_form').on 'submit', (event) ->
    if $(event.target).find('.invalid').size() > 0
      alert("You cannot sell more shares than you own.")
      event.preventDefault()
