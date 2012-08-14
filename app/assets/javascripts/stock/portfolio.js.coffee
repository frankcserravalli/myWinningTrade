$ ->
  update = ->
    $.ajax
      url: "/stock/portfolio"
      success: (html) ->
        $(".portfolio-list").replaceWith(html)
  setInterval(update, 60000)


