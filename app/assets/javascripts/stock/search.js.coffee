$(document).ready ->
  # TODO: do not allow non alphanumeric characters to even be input

  $('#stock-search form').submit (e) ->
    input_elem = $('input.stock_name',this)

    # fetch value, strip non alphanumeric characters and uppercase
    symbol = input_elem.val().replace(/\W+/g,'').toUpperCase()

    # update the input with the stripped value
    input_elem.val(symbol)

    # do nothing if there's no symbol to move to
    return false if symbol == ''

    # move to stock show page
    path = '/stock/' + symbol
    window.location = path

    # prevent form submission
    e.preventDefault()
