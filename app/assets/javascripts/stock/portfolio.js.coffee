$ ->
  setInterval ($('.portfolio-list').each (index, stock_item) ->
    $.ajax
      url: "/stock/portfolio"
      success: (html) ->
        $(stock_item).replaceWith(html)
  ), 60000

