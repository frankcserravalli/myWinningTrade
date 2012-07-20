$(document).ready ->
  $('#stock-search form').submit (e) ->
    symbol = $('input.stock_name',this).val()
    path = '/stock/' + symbol
    window.location = path
    e.preventDefault()
