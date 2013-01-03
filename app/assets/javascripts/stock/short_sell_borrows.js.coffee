$ ->
  $('#short_sell_borrow_volume').on 'keyup change', (event) ->
    volume = parseFloat($(event.target).val().replace('$', ''));

    if isNaN(volume) || volume <= 0
      $("#borrow_price_calculation .notice").html("Volume must be greater than 0")
    else
      cost_to_purchase = parseFloat($('#borrow_price').html().replace('$', ''))*volume
      $('#borrow_price_calculation .amount').html('$'+ cost_to_purchase.formatMoney(2, '.', ','))
      $("#borrow_price_calculation .notice").html(" ");

  $('#short_sell_borrow_form').on 'submit', (event) ->
    if $(event.target).find('.invalid').size() > 0
      alert("Invalid borrow options.")
      event.preventDefault()
