$(document).ready ->
  # TODO: do not allow non alphanumeric characters to even be input

  $('#stock-search form').submit (e) ->
    input_elem = $('input.stock-name',this)

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

  $("#stock-search .stock-name").autocomplete
    source: '/stock/search'
    select: (event, ui) ->
      window.location = "/stock/#{ui.item.symbol}"
      false
    focus: (event, ui) ->
      $("#stock-search .stock-name").val(ui.item.symbol)
      false

  .data("autocomplete")._renderItem = (ul, item) ->
    $("<li></li>").data('item.autocomplete', item)
                  .append("<a><span class='tip'>#{item.exchDisp}</span> #{item.symbol} <br /><small>#{item.name}</small></a>")
                  .appendTo(ul)
